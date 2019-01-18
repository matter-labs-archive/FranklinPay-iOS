//
//  PaddableTree.swift
//  MerkleTools
//
//  Created by Alexander Vlasov on 22.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation

public protocol ContentProtocol {
    var data: Data {get}
    func getHash(_ hasher: TreeHasher) -> Data
    func isEqualTo(_ other: ContentProtocol) -> Bool
}

public protocol TreeNodeProtocol {
    var data: Data {get}
    var isLeaf: Bool {get}
    var leftChild: TreeNodeProtocol? {get}
    var rightChild: TreeNodeProtocol? {get}
    var parent: TreeNodeProtocol? {get set}
    func isEqualTo(_ other: TreeNodeProtocol) -> Bool
    func getHash(_ hasher: TreeHasher) -> Data
}

public class TreeNode: TreeNodeProtocol, CustomStringConvertible {
    public var description: String {
        var str = ""
        if self.isLeaf {
            str += "Leaf" + "\n"
            str += "Data: " + self.data.toHexString() + " \n"
            str += "Hash: " + self.getHash(self.hasher).toHexString() + "\n"
        } else {
            str += "Node" + "\n"
            if self.leftChild != nil && self.rightChild != nil {
                str += "Left hash: " + self.leftChild!.getHash(self.hasher).toHexString() + " Right hash: " + self.rightChild!.getHash(self.hasher).toHexString() + "\n"
            }
            str += "Hash: " + self.getHash(self.hasher).toHexString() + "\n"
        }
        if self.parent == nil {
            str += "No parent"
        } else {
            str += "Has parent\n"
            str += self.parent!.data.toHexString() + "\n"
        }
        return str
    }
    
    public init(_ data: Data, hasher: TreeHasher) {
        self.hasher = hasher
        self.data = data
        self.isLeaf = true
    }
    
    public init(_ leftChild: TreeNodeProtocol, _ rightChild: TreeNodeProtocol, hasher: TreeHasher) {
        self.leftChild = leftChild
        self.rightChild = rightChild
        self.hasher = hasher
        self.data = self.leftChild!.getHash(self.hasher) + self.rightChild!.getHash(hasher)
        self.isLeaf = false
        self.leftChild!.parent = self
        self.rightChild!.parent = self
    }
    
    public var isLeaf: Bool
    public var data: Data
    public var hasher: TreeHasher
    public var leftChild: TreeNodeProtocol?
    public var rightChild: TreeNodeProtocol?
    public var parent: TreeNodeProtocol?
    
    public func isEqualTo(_ other: TreeNodeProtocol) -> Bool {
        return self.data == other.data
    }
    
    public func getHash(_ hasher: TreeHasher) -> Data {
        return hasher.hash(self.data)
    }
}

public struct PaddabbleTree {
    public var hasher: TreeHasher
    public var content: [TreeNodeProtocol] = [TreeNodeProtocol]()
    public var paddingElement: ContentProtocol
    public var root: TreeNodeProtocol?

    public var merkleRoot: Data? {
        return self.root?.data
//        return self.root?.getHash(self.hasher)
    }
    
    public init(_ content: [ContentProtocol], _ paddingElement: ContentProtocol) {
        self.hasher = TreeHasher()
        self.paddingElement = paddingElement
        self.content = content.map { (c) -> TreeNodeProtocol in
            let leafData = c.getHash(self.hasher)
            return TreeNode(leafData, hasher: self.hasher)
//            return TreeNode(c.data, hasher: self.hasher)
        }
        self.root = self.assembleTree(self.content)
    }
    
    public init(_ hasher: TreeHasher, _ content: [ContentProtocol], _ paddingElement: ContentProtocol) {
        self.hasher = hasher
        self.paddingElement = paddingElement
        self.content = content.map { (c) -> TreeNodeProtocol in
            let leafData = c.getHash(self.hasher)
            return TreeNode(leafData, hasher: self.hasher)
//            return TreeNode(c.data, hasher: self.hasher)
        }
        self.root = self.assembleTree(self.content)
    }
    
    public mutating func assembleTree(_ content: [TreeNodeProtocol]) -> TreeNodeProtocol {
        var thisLevelNodes = [TreeNodeProtocol]()
        let numLeaves = content.count
        if numLeaves == 1 {
            thisLevelNodes.append(content[0])
            return thisLevelNodes[0]
        }
        for i in stride(from: 0, to: numLeaves-(numLeaves % 2), by: 2) {
            let leftIndex = i
            let rightIndex = i + 1
            let leftChild = content[leftIndex]
            let rightChild = content[rightIndex]
            let thisLevelNode = TreeNode(leftChild, rightChild, hasher: self.hasher)
            thisLevelNodes.append(thisLevelNode)
            if numLeaves == 2 {
                return thisLevelNode
            }
        }
        if numLeaves % 2 == 1 {
            let leftIndex = numLeaves - 1
            let paddingNode = TreeNode(self.paddingElement.data, hasher: self.hasher)
            let leftChild = content[leftIndex]
            let thisLevelNode = TreeNode(leftChild, paddingNode, hasher: self.hasher)
            thisLevelNodes.append(thisLevelNode)
        }
        return self.assembleTree(thisLevelNodes)
    }
    
    public func makeBinaryProof(_ contentIndex: Int) -> Data? {
        if contentIndex >= self.content.count {
            return nil
        }
        if self.merkleRoot == nil {
            return nil
        }
        var leaf = self.content[contentIndex]
        if leaf.parent == nil {
            if leaf.data != self.merkleRoot {
                return nil
            }
//            if leaf.getHash(self.hasher) != self.merkleRoot {
//                return nil
//            }
            return Data()
        }
        var proof = Data()
        while leaf.parent != nil {
            if leaf.parent!.leftChild!.isEqualTo(leaf) {
                proof.append(Data([0x01])) // right element is provided
                proof.append(leaf.parent!.rightChild!.getHash(self.hasher))
            } else if leaf.parent!.rightChild!.isEqualTo(leaf) {
                proof.append(Data([0x00])) // left element is provided
                proof.append(leaf.parent!.leftChild!.getHash(self.hasher))
            } else {
                return nil
            }
            let parent = leaf.parent!
            leaf = parent
        }
        return proof
    }
    
    public static func verifyBinaryProof(content: ContentProtocol, proof: Data, expectedRoot: Data) -> Bool {
        return verifyBinaryProof(content: content, proof: proof, expectedRoot: expectedRoot, hasher: TreeHasher())
    }
    
    public static func verifyBinaryProof(content: ContentProtocol, proof: Data, expectedRoot: Data, hasher: TreeHasher) -> Bool {
        if proof.count % 33 != 0 {
            return false
        }
        let numLevels = proof.count / 33
        var hash = content.getHash(hasher)
        if numLevels == 0 {
            return hash == expectedRoot
        }
        for i in 0 ..< numLevels {
            let leftOrRight = proof[33*i]
            let data = Data(proof[33*i+1 ... 33*i+32])
            if leftOrRight == 0 {
                hash = hasher.hash(data + hash)
            } else if leftOrRight == 1 {
                hash = hasher.hash(hash + data)
            } else {
                return false
            }
        }
        return hash == expectedRoot
    }
}
