import Foundation
import SpriteKit
import SwiftUI
import Combine

class GameScene: SKScene, SKPhysicsContactDelegate {

    weak var gameManager: GameManager?

    var cameraManager = CameraManager()
    var trajectoryRenderer = TrajectoryRenderer()

    var slingshot: SlingshotNode!
    var animal: AnimalNode!
    var hoop: HoopNode!
    var stars: [StarNode] = []
    var trampolines: [TrampolineNode] = []
    var fans: [FanNode] = []
    var iceBlocks: [IceBlockNode] = []
    var walls: [SKShapeNode] = []
    var waterZones: [SKShapeNode] = []

    private var ground: SKShapeNode!
    private var backgroundLayer: SKNode!

    private var isDragging: Bool = false
    private var lastFrameTime: TimeInterval = 0

    private var levelData: LevelData!
    private var particlesLayer: SKNode!
    private var worldBounds: CGRect = .zero

    private var scoredHandled: Bool = false
    private var failedHandled: Bool = false
    private var stoppedFrames: Int = 0

    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: GamePhysicsConfig.gravity * GamePhysicsConfig.gravityMultiplier)
        physicsWorld.speed = 1.0

        backgroundColor = UIColor(red: 0.5, green: 0.8, blue: 0.95, alpha: 1.0)

        let cameraNode = SKCameraNode()
        camera = cameraNode
        cameraNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(cameraNode)
        cameraManager.setup(camera: cameraNode, scene: self)

        particlesLayer = SKNode()
        addChild(particlesLayer)
        particlesLayer.zPosition = 50

        backgroundLayer = SKNode()
        backgroundLayer.zPosition = -10
        addChild(backgroundLayer)

        worldBounds = CGRect(origin: .zero, size: size)
        setupWorldBoundaries()
    }

    func loadLevel(_ data: LevelData) {
        levelData = data

        clearLevel()
        setupTheme(data.theme)
        setupGround(theme: data.theme)
        setupSlingshot(at: data.launchPosition)
        setupAnimal(type: data.animal ?? (gameManager?.currentAnimal ?? .cat))
        setupHoop(position: data.hoopPosition, movement: data.hoopMovement)
        setupStars(positions: data.stars)
        setupObstacles(data.obstacles)
        trajectoryRenderer.setup(in: self)
        placeAnimalAtLaunchPoint()

        gameManager?.shotsRemaining = data.parShots
        gameManager?.shotsUsed = 0
        gameManager?.starsCollected = 0
        gameManager?.totalStarsInLevel = data.stars.count
        gameManager?.levelScore = 0
        gameManager?.lastScoreInfo = nil
        gameManager?.abilityAvailable = true
        gameManager?.scoreManager.resetScore()

        scoredHandled = false
        failedHandled = false
        stoppedFrames = 0

        cameraManager.setPosition(CGPoint(x: size.width / 2, y: size.height / 2))
        cameraManager.reset()
    }

    private func clearLevel() {
        slingshot?.removeFromParent()
        animal?.removeFromParent()
        hoop?.removeFromParent()
        stars.forEach { $0.removeFromParent() }
        trampolines.forEach { $0.removeFromParent() }
        fans.forEach { $0.removeFromParent() }
        iceBlocks.forEach { $0.removeFromParent() }
        walls.forEach { $0.removeFromParent() }
        waterZones.forEach { $0.removeFromParent() }
        ground?.removeFromParent()
        backgroundLayer?.removeAllChildren()

        stars.removeAll()
        trampolines.removeAll()
        fans.removeAll()
        iceBlocks.removeAll()
        walls.removeAll()
        waterZones.removeAll()
    }

    private func setupTheme(_ theme: ThemeType) {
        let topColor = SKColor(hexString: theme.skyColor.top)
        let bottomColor = SKColor(hexString: theme.skyColor.bottom)

        let gradientTexture = makeGradientTexture(size: size, top: topColor, bottom: bottomColor)
        let bg = SKSpriteNode(texture: gradientTexture)
        bg.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bg.zPosition = -10
        backgroundLayer.addChild(bg)

        addThemeDecorations(theme: theme)
    }

    private func makeGradientTexture(size: CGSize, top: SKColor, bottom: SKColor) -> SKTexture {
        UIGraphicsBeginImageContext(size)
        guard let ctx = UIGraphicsGetCurrentContext() else { return SKTexture() }
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colors = [top.cgColor, bottom.cgColor] as CFArray
        if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: nil) {
            ctx.drawLinearGradient(gradient,
                                     start: CGPoint(x: size.width / 2, y: size.height),
                                     end: CGPoint(x: size.width / 2, y: 0),
                                     options: [])
        }
        let img = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return SKTexture(image: img)
    }

    private func addThemeDecorations(theme: ThemeType) {
        switch theme {
        case .sunnyPark:
            for i in 0..<3 {
                let cloud = makeCloud()
                cloud.position = CGPoint(
                    x: CGFloat(50 + i * 130),
                    y: size.height - 80 - CGFloat(i * 40)
                )
                backgroundLayer.addChild(cloud)
            }
        case .candyWorld:
            let colors: [SKColor] = [.systemPink, .systemPurple, .systemTeal]
            for i in 0..<5 {
                let candy = SKShapeNode(circleOfRadius: 6 + CGFloat(arc4random_uniform(6)))
                candy.fillColor = colors[Int(arc4random_uniform(UInt32(colors.count)))]
                candy.strokeColor = .white
                candy.lineWidth = 1
                candy.position = CGPoint(
                    x: CGFloat(30 + i * 80),
                    y: size.height - 60 - CGFloat(arc4random_uniform(120)))
                backgroundLayer.addChild(candy)
            }
        case .arctic:
            for _ in 0..<15 {
                let flake = SKShapeNode(circleOfRadius: 2 + CGFloat(arc4random_uniform(3)))
                flake.fillColor = SKColor.white.withAlphaComponent(0.9)
                flake.strokeColor = .clear
                let startX = CGFloat(arc4random_uniform(UInt32(self.size.width)))
                let startY = self.size.height + 20 + CGFloat(arc4random_uniform(UInt32(self.size.height)))
                flake.position = CGPoint(x: startX, y: startY)
                backgroundLayer.addChild(flake)
                let drift = SKAction.moveBy(x: CGFloat(arc4random_uniform(40)) - 20,
                                            y: -(self.size.height + 200),
                                            duration: 10 + Double(arc4random_uniform(10)))
                let reset = SKAction.run { [weak self] in
                    guard let self = self else { return }
                    flake.position = CGPoint(x: CGFloat(arc4random_uniform(UInt32(self.size.width))),
                                              y: self.size.height + 50)
                }
                flake.run(SKAction.repeatForever(SKAction.sequence([drift, reset])))
            }
        case .factory:
            for i in 0..<3 {
                let pipe = SKShapeNode(rectOf: CGSize(width: 16, height: 180))
                pipe.fillColor = SKColor(red: 0.5, green: 0.55, blue: 0.6, alpha: 1.0)
                pipe.strokeColor = SKColor(red: 0.3, green: 0.35, blue: 0.4, alpha: 1.0)
                pipe.lineWidth = 2
                pipe.position = CGPoint(x: 40 + CGFloat(i) * 120, y: 90)
                backgroundLayer.addChild(pipe)
            }
        }
    }

    private func makeCloud() -> SKNode {
        let cloud = SKNode()
        let base = SKShapeNode(circleOfRadius: 22)
        base.fillColor = .white
        base.strokeColor = .clear
        base.alpha = 0.9
        cloud.addChild(base)

        let puff1 = SKShapeNode(circleOfRadius: 16)
        puff1.fillColor = .white
        puff1.strokeColor = .clear
        puff1.position = CGPoint(x: 18, y: 6)
        puff1.alpha = 0.9
        cloud.addChild(puff1)

        let puff2 = SKShapeNode(circleOfRadius: 14)
        puff2.fillColor = .white
        puff2.strokeColor = .clear
        puff2.position = CGPoint(x: -18, y: 4)
        puff2.alpha = 0.9
        cloud.addChild(puff2)
        return cloud
    }

    private func setupGround(theme: ThemeType) {
        let groundHeight: CGFloat = 90
        let shape = SKShapeNode(rect: CGRect(x: 0, y: 0, width: size.width, height: groundHeight))
        shape.fillColor = SKColor(hexString: theme.groundColor)
        shape.strokeColor = .clear
        shape.position = .zero
        addChild(shape)
        ground = shape

        let physics = SKPhysicsBody(rectangleOf: CGSize(width: size.width, height: groundHeight),
                                     center: CGPoint(x: size.width / 2, y: groundHeight / 2))
        physics.isDynamic = false
        physics.restitution = 0.3
        physics.friction = 0.7
        physics.categoryBitMask = PhysicsCategories.ground
        physics.contactTestBitMask = PhysicsCategories.animal
        physics.collisionBitMask = PhysicsCategories.animal
        ground.physicsBody = physics
        ground.name = "ground"
    }

    private func setupWorldBoundaries() {
        let thickness: CGFloat = 20

        let left = SKShapeNode(rectOf: CGSize(width: thickness, height: size.height * 1.5))
        left.position = CGPoint(x: -thickness / 2, y: size.height / 2)
        left.fillColor = .clear
        left.strokeColor = .clear
        let leftBody = SKPhysicsBody(rectangleOf: CGSize(width: thickness, height: size.height * 1.5))
        leftBody.isDynamic = false
        leftBody.categoryBitMask = PhysicsCategories.boundary
        leftBody.contactTestBitMask = PhysicsCategories.animal
        leftBody.collisionBitMask = PhysicsCategories.animal
        left.physicsBody = leftBody
        left.name = "boundary"
        addChild(left)

        let right = SKShapeNode(rectOf: CGSize(width: thickness, height: size.height * 1.5))
        right.position = CGPoint(x: size.width + thickness / 2, y: size.height / 2)
        right.fillColor = .clear
        right.strokeColor = .clear
        let rightBody = SKPhysicsBody(rectangleOf: CGSize(width: thickness, height: size.height * 1.5))
        rightBody.isDynamic = false
        rightBody.categoryBitMask = PhysicsCategories.boundary
        rightBody.contactTestBitMask = PhysicsCategories.animal
        rightBody.collisionBitMask = PhysicsCategories.animal
        right.physicsBody = rightBody
        right.name = "boundary"
        addChild(right)

        let top = SKShapeNode(rectOf: CGSize(width: size.width * 1.5, height: thickness))
        top.position = CGPoint(x: size.width / 2, y: size.height + thickness / 2 + 200)
        top.fillColor = .clear
        top.strokeColor = .clear
        let topBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width * 1.5, height: thickness))
        topBody.isDynamic = false
        topBody.categoryBitMask = PhysicsCategories.boundary
        topBody.contactTestBitMask = PhysicsCategories.animal
        topBody.collisionBitMask = PhysicsCategories.animal
        top.physicsBody = topBody
        top.name = "boundary"
        addChild(top)
    }

    private func setupSlingshot(at position: CGPoint) {
        slingshot = SlingshotNode()
        slingshot.setup(frameSize: size, position: position)
        addChild(slingshot)
    }

    private func setupAnimal(type: AnimalType) {
        animal = AnimalNode()
        animal.configure(type: type)
        addChild(animal)
    }

    private func placeAnimalAtLaunchPoint() {
        guard let slingshot = self.slingshot else { return }
        animal.resetForNewShot()
        let worldLaunchPos = slingshot.position + slingshot.launchPosition
        animal.position = worldLaunchPos
        animal.zPosition = 10
    }

    private func setupHoop(position: CGPoint, movement: HoopMovementData) {
        hoop = HoopNode()
        hoop.setup(hoopPosition: position, movement: movement)
        hoop.onScore = { [weak self] info in
            self?.handleScore(info: info)
        }
        addChild(hoop)
    }

    private func setupStars(positions: [CGPoint]) {
        for (index, pos) in positions.enumerated() {
            let star = StarNode()
            star.setup(position: pos)
            star.starIndex = index
            star.onCollected = { [weak self] in
                self?.gameManager?.collectStar()
            }
            stars.append(star)
            addChild(star)
        }
    }

    private func setupObstacles(_ obstacles: [ObstacleData]) {
        for obs in obstacles {
            switch obs.type {
            case .trampoline:
                let t = TrampolineNode()
                t.setup(position: obs.position, size: obs.size)
                trampolines.append(t)
                addChild(t)

            case .fan:
                let f = FanNode()
                let angle = obs.extra["angle"] ?? 0
                let force = obs.extra["force"] ?? Double(GamePhysicsConfig.fanForce)
                f.setup(position: obs.position,
                         size: min(obs.size.width, obs.size.height),
                         rotationSpeed: 5,
                         forceRadius: 140,
                         angleDegrees: CGFloat(angle))
                f.forceStrength = CGFloat(force)
                fans.append(f)
                addChild(f)

            case .iceBlock:
                let ice = IceBlockNode()
                ice.setup(position: obs.position, size: obs.size)
                iceBlocks.append(ice)
                addChild(ice)

            case .wall, .movingPlatform:
                let wallRect = CGRect(origin: CGPoint(x: -obs.size.width/2, y: -obs.size.height/2),
                                       size: obs.size)
                let wall = SKShapeNode(rect: wallRect, cornerRadius: 4)
                wall.fillColor = SKColor(red: 0.6, green: 0.4, blue: 0.25, alpha: 1.0)
                wall.strokeColor = SKColor(red: 0.35, green: 0.2, blue: 0.1, alpha: 1.0)
                wall.lineWidth = 2
                wall.position = obs.position
                let wallPhysics = SKPhysicsBody(rectangleOf: obs.size)
                wallPhysics.isDynamic = false
                wallPhysics.restitution = 0.2
                wallPhysics.friction = 0.5
                wallPhysics.categoryBitMask = PhysicsCategories.ground
                wallPhysics.contactTestBitMask = PhysicsCategories.animal
                wallPhysics.collisionBitMask = PhysicsCategories.animal
                wall.physicsBody = wallPhysics
                wall.name = "wall"
                walls.append(wall)
                addChild(wall)

            case .waterZone:
                let waterRect = CGRect(origin: CGPoint(x: -obs.size.width/2, y: -obs.size.height/2),
                                       size: obs.size)
                let water = SKShapeNode(rect: waterRect, cornerRadius: 8)
                water.fillColor = SKColor(red: 0.2, green: 0.6, blue: 0.95, alpha: 0.6)
                water.strokeColor = SKColor(red: 0.4, green: 0.8, blue: 1.0, alpha: 0.8)
                water.lineWidth = 2
                water.position = obs.position
                let waterPhysics = SKPhysicsBody(rectangleOf: obs.size)
                waterPhysics.isDynamic = false
                waterPhysics.categoryBitMask = PhysicsCategories.water
                waterPhysics.contactTestBitMask = PhysicsCategories.animal
                waterPhysics.collisionBitMask = 0
                water.physicsBody = waterPhysics
                water.name = "water"
                waterZones.append(water)
                addChild(water)
            }
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let gm = gameManager else { return }
        guard !gm.isPaused else { return }

        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        if gm.gameState == .flying && animal.type == .cat && gm.abilityAvailable {
            animal.useCatAbility()
            gm.useAbility()
            return
        }

        guard gm.gameState == .ready || gm.gameState == .aiming else { return }

        let animalFrame = animal.frame.insetBy(dx: -30, dy: -30)
        let launchPos = slingshot.position + slingshot.launchPosition
        let nearLaunch = hypot(location.x - launchPos.x, location.y - launchPos.y) < 110
        let inLaunchQuadrant = location.x < 220 && location.y < 380 && location.y > 60

        if animalFrame.contains(location) || nearLaunch || inLaunchQuadrant || gm.gameState == .aiming {
            isDragging = true
            gm.gameState = .aiming
            SoundManager.shared.playSound("slingshot_pull")
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isDragging else { return }
        guard let touch = touches.first else { return }
        guard let gm = gameManager, gm.gameState == .aiming else { return }

        let location = touch.location(in: self)
        let launchPos = slingshot.position + slingshot.launchPosition

        var offsetX = location.x - launchPos.x
        var offsetY = location.y - launchPos.y

        let dist = sqrt(offsetX * offsetX + offsetY * offsetY)

        if dist > GamePhysicsConfig.maxPullDistance {
            let ratio = GamePhysicsConfig.maxPullDistance / dist
            offsetX *= ratio
            offsetY *= ratio
        }

        if offsetY > 35 { offsetY = 35 }
        if offsetX > 35 { offsetX = 35 }

        let clampedX = max(24, min(size.width - 24, launchPos.x + offsetX))
        let clampedY = max(90 + 24, min(size.height - 50, launchPos.y + offsetY))
        let animalWorld = CGPoint(x: clampedX, y: clampedY)
        let animalLocal = CGPoint(x: clampedX - launchPos.x, y: clampedY - launchPos.y)

        animal.position = animalWorld
        animal.zPosition = 12

        slingshot.updateBands(to: animalLocal)

        let launchVel = calculateLaunchVelocity(from: animalWorld)
        trajectoryRenderer.update(startPosition: animalWorld,
                                   velocity: launchVel,
                                   gravity: GamePhysicsConfig.gravity * 150)

        let hoopWorld = convert(hoop.position, from: hoop.parent!)
        trajectoryRenderer.highlightNearHoop(hoopWorld)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isDragging else { return }
        guard let gm = gameManager, gm.gameState == .aiming else {
            isDragging = false
            return
        }
        isDragging = false
        launchAnimal()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }

    private func calculateLaunchVelocity(from draggedPos: CGPoint) -> CGVector {
        let launchPos = slingshot.position + slingshot.launchPosition
        let dx = launchPos.x - draggedPos.x
        let dy = launchPos.y - draggedPos.y
        return CGVector(dx: dx * GamePhysicsConfig.launchPower,
                         dy: dy * GamePhysicsConfig.launchPower)
    }

    private func launchAnimal() {
        guard let gm = gameManager else { return }

        let vel = calculateLaunchVelocity(from: animal.position)

        if abs(vel.dx) < 25 && abs(vel.dy) < 25 {
            placeAnimalAtLaunchPoint()
            slingshot.resetBands()
            trajectoryRenderer.hide()
            gameManager?.gameState = .ready
            return
        }

        gm.useShot()
        gm.gameState = .flying
        gm.completeTutorial()

        animal.physicsBody?.isDynamic = true
        animal.physicsBody?.velocity = vel

        slingshot.snapRelease()
        slingshot.resetBands()
        trajectoryRenderer.hide()
        trajectoryRenderer.clearGlow()

        SoundManager.shared.playSound("launch")
        HapticManager.shared.lightImpact()
    }

    func didBegin(_ contact: SKPhysicsContact) {
        let a = contact.bodyA.categoryBitMask
        let b = contact.bodyB.categoryBitMask
        let animalMask = PhysicsCategories.animal

        if (a == animalMask || b == animalMask) {
            let otherCat = a == animalMask ? b : a
            handleAnimalCollision(with: otherCat, contact: contact)
        }
    }

    private func handleAnimalCollision(with otherCategory: UInt32, contact: SKPhysicsContact) {
        guard let animal = self.animal else { return }
        let velocity = animal.physicsBody?.velocity ?? .zero

        switch otherCategory {
        case PhysicsCategories.rim:
            animal.hitRim = true
            hoop?.rimHit()
            HapticManager.shared.mediumImpact()
            SoundManager.shared.playSound("rim_hit")
            cameraManager.shake(duration: 0.15, intensity: 6)
            animal.bounceAnimation()

        case PhysicsCategories.backboard:
            animal.hitBackboard = true
            HapticManager.shared.lightImpact()
            SoundManager.shared.playSound("backboard_hit")
            animal.bounceAnimation()

        case PhysicsCategories.ground:
            handleGroundCollision(velocity: velocity)
            animal.bounceAnimation()

        case PhysicsCategories.trampoline:
            if let trampoline = findTrampoline(contact: contact) {
                animal.hitTrampoline = true
                trampoline.bounce(animal: animal)
                cameraManager.shake(duration: 0.1, intensity: 5)
                gameManager?.scoreManager.addScore(50, type: .trampoline, actionName: "Trampoline")
            }

        case PhysicsCategories.ice:
            if let ice = findIceBlock(contact: contact) {
                handleIceCollision(ice: ice, velocity: velocity)
            }
            animal.bounceAnimation()

        case PhysicsCategories.water:
            handleWaterCollision()

        case PhysicsCategories.star:
            if let star = findStar(contact: contact) {
                if !star.collected {
                    star.collect()
                }
            }

        case PhysicsCategories.boundary:
            break

        default:
            break
        }
    }

    private func handleGroundCollision(velocity: CGVector) {
        guard let animal = self.animal else { return }

        if velocity.dy < GamePhysicsConfig.groundSlamVelocity && animal.type == .panda {
            animal.usedIceSlam = true
            cameraManager.shake(duration: 0.4, intensity: 20)
            HapticManager.shared.groundSlam()
            SoundManager.shared.playSound("ability")
            showPandaSlamEffect()

            for ice in iceBlocks {
                let dist = hypot(ice.position.x - animal.position.x,
                                 ice.position.y - animal.position.y)
                if dist < 130 {
                    ice.takeDamage(amount: 3, fromGroundSlam: true)
                }
            }
        } else {
            HapticManager.shared.lightImpact()
            SoundManager.shared.playSound("bounce")
        }
    }

    private func showPandaSlamEffect() {
        guard let animal = self.animal else { return }

        for _ in 0..<10 {
            let dust = SKShapeNode(circleOfRadius: 5 + CGFloat(arc4random_uniform(6)))
            dust.fillColor = SKColor(white: 0.7, alpha: 0.8)
            dust.strokeColor = .clear
            dust.position = animal.position
            addChild(dust)
            let dx = CGFloat(arc4random_uniform(100)) - 50
            let dy = CGFloat(arc4random_uniform(40))
            let move = SKAction.moveBy(x: dx, y: -dy, duration: 0.5)
            let fade = SKAction.fadeOut(withDuration: 0.5)
            let scale = SKAction.scale(to: 0.2, duration: 0.5)
            dust.run(SKAction.sequence([SKAction.group([move, fade, scale]), .removeFromParent()]))
        }
    }

    private func handleIceCollision(ice: IceBlockNode, velocity: CGVector) {
        if let animal = self.animal, animal.type == .penguin {
            if let body = animal.physicsBody {
                let currentVx = body.velocity.dx
                let sign: CGFloat = currentVx >= 0 ? 1 : -1
                body.velocity.dx = max(abs(currentVx) * 1.5, 260) * sign
                body.friction = 0.01
            }
            SoundManager.shared.playSound("bounce")
            HapticManager.shared.lightImpact()
            return
        }

        let speed = hypot(velocity.dx, velocity.dy)
        if speed > 350 {
            ice.takeDamage(amount: 2)
        } else if speed > 200 {
            ice.takeDamage(amount: 1)
        } else {
            HapticManager.shared.lightImpact()
        }
    }

    private func handleWaterCollision() {
        guard let animal = self.animal, let body = animal.physicsBody else { return }
        showWaterSplash(at: animal.position)

        if animal.type == .otter {
            let currentVx = body.velocity.dx
            let sign: CGFloat = currentVx >= 0 ? 1 : -1
            body.velocity.dx = max(abs(currentVx) * 1.3, 220) * sign
            body.velocity.dy = 360
            HapticManager.shared.mediumImpact()
            SoundManager.shared.playSound("bounce")
        } else {
            body.velocity.dx *= 0.5
            body.velocity.dy *= 0.3
            HapticManager.shared.lightImpact()
            SoundManager.shared.playSound("bounce")
        }
    }

    private func showWaterSplash(at pos: CGPoint) {
        for _ in 0..<8 {
            let droplet = SKShapeNode(circleOfRadius: 3 + CGFloat(arc4random_uniform(3)))
            droplet.fillColor = SKColor(red: 0.4, green: 0.8, blue: 1.0, alpha: 0.8)
            droplet.strokeColor = .clear
            droplet.position = pos
            droplet.zPosition = 30
            addChild(droplet)

            let dx = CGFloat(arc4random_uniform(60)) - 30
            let dy = CGFloat(arc4random_uniform(50)) + 20
            let move = SKAction.moveBy(x: dx, y: dy, duration: 0.35)
            let fall = SKAction.moveBy(x: dx * 0.5, y: -dy * 1.2, duration: 0.35)
            let fade = SKAction.fadeOut(withDuration: 0.35)
            droplet.run(SKAction.sequence([move, SKAction.group([fall, fade]), .removeFromParent()]))
        }
    }

    private func findTrampoline(contact: SKPhysicsContact) -> TrampolineNode? {
        for t in trampolines {
            if contact.bodyA.node === t || contact.bodyB.node === t { return t }
            if contact.bodyA.node?.parent === t || contact.bodyB.node?.parent === t { return t }
        }
        return nil
    }

    private func findIceBlock(contact: SKPhysicsContact) -> IceBlockNode? {
        for ice in iceBlocks {
            if contact.bodyA.node === ice || contact.bodyB.node === ice { return ice }
        }
        return nil
    }

    private func findStar(contact: SKPhysicsContact) -> StarNode? {
        for star in stars {
            if contact.bodyA.node === star || contact.bodyB.node === star { return star }
        }
        return nil
    }

    func handleScore(info: HoopNode.ScoreInfo) {
        guard let gm = gameManager else { return }
        scoredHandled = true
        gm.recordScore(info: info)
        animal.physicsBody?.isDynamic = false
        animal.physicsBody?.velocity = .zero
        cameraManager.stopFollowing()
        showScoreEffect(info: info)
    }

    private func showScoreEffect(info: HoopNode.ScoreInfo) {
        let hoopPos = convert(hoop.position, from: hoop.parent!)

        let count = info.isSwish ? 30 : 15
        let colors: [SKColor] = [.systemRed, .systemYellow, .systemGreen, .systemBlue, .systemPink, .systemPurple]
        for _ in 0..<count {
            let confetti = SKShapeNode(rectOf: CGSize(width: 8, height: 8))
            confetti.fillColor = colors[Int(arc4random_uniform(UInt32(colors.count)))]
            confetti.strokeColor = .clear
            confetti.position = CGPoint(x: hoopPos.x + CGFloat(arc4random_uniform(40)) - 20,
                                        y: hoopPos.y)
            confetti.zPosition = 60
            addChild(confetti)

            let dx = CGFloat(arc4random_uniform(200)) - 100
            let dy = 100 + CGFloat(arc4random_uniform(100))
            let move = SKAction.moveBy(x: dx, y: -dy, duration: 1.2)
            let fade = SKAction.fadeOut(withDuration: 1.2)
            let rot = SKAction.rotate(byAngle: 6.28, duration: 1.0)
            confetti.run(SKAction.sequence([SKAction.group([move, fade, rot]), .removeFromParent()]))
        }
    }

    private func checkOutOfBounds() -> Bool {
        guard let animal = self.animal else { return false }
        let margin: CGFloat = 150
        if animal.position.x < -margin || animal.position.x > size.width + margin ||
            animal.position.y < -margin {
            return true
        }
        return false
    }

    private func checkStopped() -> Bool {
        guard let animal = self.animal, let physics = animal.physicsBody else { return false }
        let speed = hypot(physics.velocity.dx, physics.velocity.dy)
        return speed < 15 && abs(physics.angularVelocity) < 0.5
    }

    override func update(_ currentTime: TimeInterval) {
        let delta = lastFrameTime == 0 ? 0.016 : currentTime - lastFrameTime
        lastFrameTime = currentTime
        guard let gm = gameManager else { return }
        if gm.isPaused {
            physicsWorld.speed = 0
            return
        } else {
            physicsWorld.speed = 1
        }

        cameraManager.update(currentTime, deltaTime: delta)

        if let hoop = self.hoop {
            hoop.updateMovement(currentTime: currentTime)
        }
        for fan in fans {
            fan.update(currentTime: currentTime, deltaTime: delta)
        }
        if gm.gameState == .flying {
            for fan in fans {
                fan.applyWindForce(to: animal)
            }
        }

        guard let animal = self.animal else { return }

        if gm.gameState == .flying {
            hoop?.animalPassedAboveRim(animal)
            if let hoop = self.hoop, !scoredHandled {
                if hoop.checkScore(animal: animal) {
                    scoredHandled = true
                }
            }

            if checkOutOfBounds() && !scoredHandled && !failedHandled {
                failedHandled = true
                handleShotEnd()
                return
            }

            if animal.position.y < 130 {
                if checkStopped() {
                    stoppedFrames += 1
                } else {
                    stoppedFrames = 0
                }
                if stoppedFrames > 40 && !scoredHandled && !failedHandled {
                    failedHandled = true
                    handleShotEnd()
                    return
                }
            }
        }
    }

    private func handleShotEnd() {
        guard let gm = gameManager else { return }
        cameraManager.stopFollowing()
        HapticManager.shared.warning()
        gm.handleShotFailed()

        if gm.shotsRemaining > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.resetForNextShot()
            }
        }
    }

    private func resetForNextShot() {
        placeAnimalAtLaunchPoint()
        slingshot.resetBands()
        trajectoryRenderer.hide()

        scoredHandled = false
        failedHandled = false
        stoppedFrames = 0
        gameManager?.abilityAvailable = true
    }

    func resetAllStateForRetry() {
        scoredHandled = false
        failedHandled = false
        stoppedFrames = 0

        stars.forEach { $0.removeFromParent() }
        stars.removeAll()
        setupStars(positions: levelData.stars)

        trampolines.forEach { $0.reset() }
        iceBlocks.forEach { $0.reset() }
        hoop?.reset()

        placeAnimalAtLaunchPoint()
        slingshot.resetBands()
        trajectoryRenderer.hide()
        cameraManager.reset()
    }
}

extension SKColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
