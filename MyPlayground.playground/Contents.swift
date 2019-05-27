import UIKit
import SceneKit
import Foundation

let v1 = float4(5.0, 5.0, 5.0, 1.0)
let v2 = float4(0.0, 0.0, 0.0, 1.0)

let v1v2 = v2-v1

print(v1v2)

let distance = length(v1v2)
print(distance)
