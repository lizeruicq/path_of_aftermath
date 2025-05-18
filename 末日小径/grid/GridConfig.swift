//
//  GridConfig.swift
//  末日小径
//
//  Created for 末日小径 game
//

import Foundation

class GridConfig {
    
    // 网格尺寸
    let rows: Int
    let columns: Int
    
    // 存储可建造网格的数组
    private var buildableCells: [[Bool]]
    
    // 初始化方法 - 默认所有网格都不可建造
    init(rows: Int, columns: Int) {
        self.rows = rows
        self.columns = columns
        
        // 初始化二维数组，默认所有值为false（不可建造）
        self.buildableCells = Array(repeating: Array(repeating: false, count: columns), count: rows)
    }
    
    // 检查指定位置是否可以建造
    func isCellBuildable(row: Int, column: Int) -> Bool {
        // 检查索引是否有效
        guard row >= 0 && row < rows && column >= 0 && column < columns else {
            return false
        }
        
        return buildableCells[row][column]
    }
    
    // 设置指定位置是否可以建造
    func setCellBuildable(row: Int, column: Int, buildable: Bool) {
        // 检查索引是否有效
        guard row >= 0 && row < rows && column >= 0 && column < columns else {
            return
        }
        
        buildableCells[row][column] = buildable
    }
    
    // 从配置文件加载数据
    func loadFromFile(fileName: String) -> Bool {
        // 获取文件路径
        guard let path = Bundle.main.path(forResource: fileName, ofType: "json") else {
            print("配置文件未找到: \(fileName).json")
            return false
        }
        
        do {
            // 读取文件内容
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            
            // 解析JSON
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let gridData = json["grid"] as? [[Int]] {
                
                // 确保数据尺寸正确
                guard gridData.count == rows else {
                    print("配置文件行数不匹配")
                    return false
                }
                
                for (rowIndex, row) in gridData.enumerated() {
                    guard row.count == columns else {
                        print("配置文件第\(rowIndex)行列数不匹配")
                        return false
                    }
                    
                    for (colIndex, value) in row.enumerated() {
                        // 1表示可建造，0表示不可建造
                        buildableCells[rowIndex][colIndex] = (value == 1)
                    }
                }
                
                return true
            } else {
                print("配置文件格式错误")
                return false
            }
        } catch {
            print("加载配置文件失败: \(error.localizedDescription)")
            return false
        }
    }
    
    // 创建默认配置（用于测试或配置文件加载失败时）
    func createDefaultConfig() {
        // 重置所有单元格为不可建造
        buildableCells = Array(repeating: Array(repeating: false, count: columns), count: rows)
        
        // 设置一些默认的可建造区域（例如，中间区域）
        let startRow = rows / 4
        let endRow = rows * 3 / 4
        let startCol = columns / 4
        let endCol = columns * 3 / 4
        
        for row in startRow..<endRow {
            for col in startCol..<endCol {
                buildableCells[row][col] = true
            }
        }
    }
}
