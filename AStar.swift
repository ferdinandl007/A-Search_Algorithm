import Foundation
import UIKit

class AStar {
    class Node: Comparable {
        var parent: Node?
        var position: CGPoint
        var g: Double
        var h: Double

        init(parent: Node?, position: CGPoint, g: Double, h: Double) {
            self.parent = parent
            self.position = position
            self.g = g
            self.h = h
        }

        init() {
            parent = nil
            position = CGPoint()
            g = 0
            h = 0
        }

        static func < (lhs: AStar.Node, rhs: AStar.Node) -> Bool {
            return (lhs.g + lhs.h) < (rhs.g + rhs.h)
        }

        static func == (lhs: AStar.Node, rhs: AStar.Node) -> Bool {
            return (lhs.g + lhs.h) == (rhs.g + rhs.h)
        }
    }

    private var open: [Node]
    private var closed: [Node]
    private var path: [Node]
    private var map: [[Int]]
    private var now: Node
    private var start: CGPoint
    private var end: CGPoint
    private var diag: Bool

    ///  initialises a navigational instance
    /// - Parameters:
    ///   - map:  integer map  with values between 0 to 2
    ///   - start:   starting point
    ///   - diag:    diagonal movements allowed
    init(map: [[Int]], start: CGPoint, diag: Bool) {
        open = []
        closed = []
        path = []
        self.map = map
        now = Node(parent: nil, position: start, g: 0, h: 0)
        self.start = start
        end = CGPoint()
        self.diag = diag
        // If the source is out of range.
        if !isValid(start.xI, start.yI) {
            print("Source is invalid")
        }
        // Either the source or the destination is blocked.
        if map[start.xI][start.yI] == 1 {
            print("Source is blocked")
        }
    }

    /// Finds path to xend/yend or returns nil
    /// - Parameter end: end coordinates of the target position
    func findPathTo(end: CGPoint) -> [Node]? {
        // If the destination is out of range.
        if !isValid(end.xI, end.yI) {
            print("Destination is invalid")
            return []
        }

        // destination is blocked.
        if map[end.xI][end.yI] == 1 {
            print("destination is blocked")
            return []
        }

        self.end = end
        closed.append(now)
        addNeigborsToOpenList()
        while now.position.x != end.x || now.position.y != end.y {
            if open.isEmpty { // Nothing to examine
                return nil
            }
            now = open[0]
            open.remove(at: 0)
            closed.append(now)
            addNeigborsToOpenList()
        }
        path.insert(now, at: 0)
        while now.position.x != start.x || now.position.y != start.y {
            now = now.parent!
            path.insert(now, at: 0)
        }

        return path
    }

    /// Looks in a given List<> for a node
    private func findNeighborInList(_ array: [Node], _ node: Node) -> Bool {
        return (array.first { $0.position.x == node.position.x && $0.position.y == node.position.y } != nil)
    }

    /// Calulate distance between this.now and xend/yend
    /// -@return (int) distance
    private func distance(_: CGPoint) -> Double {
        if diag { // if diagonal movement is alloweed
            return hypot(now.position.xD - end.xD, now.position.yD - end.yD) // return hypothenuse
        } else {
            return abs(now.position.xD - end.xD) - abs(now.position.yD - end.yD) // else return "Manhattan distance
        }
    }

    private func addNeigborsToOpenList() {
        var node = Node()
        for x in -1 ... 1 {
            for y in -1 ... 1 {
                if !diag && x != 0 && y != 0 {
                    continue // skip if diagonal movement is not allowed
                }
                node = Node(parent: now, position: CGPoint(x: now.position.xI + x, y: now.position.yI + y), g: now.g + Double(y), h: distance(CGPoint(x: x, y: y)))

                if x != 0 || y != 0,
                    now.position.xI + x >= 0, now.position.xI + x < map[0].count, // check maze boundaries
                    now.position.yI + y >= 0, now.position.yI + y < map.count,
                    map[now.position.yI + y][now.position.xI + x] != 1, // check if square is walkable
                    !findNeighborInList(open, node), !findNeighborInList(closed, node) {
                    node.g = node.parent!.g + 1 // Horizontal/vertical cost = 1.0
                    node.g += Double(map[now.position.yI + y][now.position.xI + x]) // add movement cost for this square
                    node.g += map[now.position.yI + y][now.position.xI + x] == 2 ? 3 : 0
                    // diagonal cost = sqrt(hor_cost² + vert_cost²)
                    // in this example the cost would be 12.2 instead of 11
                    if diag, x != 0, y != 0 {
                        node.g += 0.4 // Diagonal movement cost = 1.4
                    }
                    open.append(node)
                }
            }
        }
        open.sort()
    }

    private func isValid(_ row: Int, _ col: Int) -> Bool {
        return (row >= 0) && (row < map.count)
            && (col >= 0) && (col < map.first!.count)
    }
}

extension CGPoint {
    var xD: Double { return Double(x) }
    var yD: Double { return Double(y) }
    var xI: Int { return Int(x) }
    var yI: Int { return Int(y) }
}
