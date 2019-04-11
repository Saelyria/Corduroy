import Nimble

func waitUntilNextFrame() {
//    waitUntil { (done) in
//        DispatchQueue.main.async(execute: done)
//    }
}

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
