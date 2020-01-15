//
//  Cli.swift
//  cococo
//
//  Created by Michael Heinzl on 10.01.20.
//  Copyright © 2020 mySugr GmbH. All rights reserved.
//

import Foundation
import SPMUtility
import cococoLibrary

class Cli {
	
	let io = IO()
	
	func main() {
		do {
			let parser = ArgumentParser(
				usage: "<xcresult> [-e <excluded-file-extension1> ...]",
				overview: "Converts Xcode's xcresult archive into SonarCloud's XML code coverage format"
			)
			let archive = parser.add(
				positional: "xcresult",
				kind: String.self,
				optional: false,
				usage: "Path to the xcresult",
				completion: .filename
			)
			let excluded = parser.add(
				option: "--excluded",
				shortName: "-e",
				kind: [String].self,
				strategy: .upToNextOption,
				usage: "Multiple file extensions which are excluded from processing",
				completion: ShellCompletion.none
			)
			
			let argsv = Array(CommandLine.arguments.dropFirst())
			let parsedArguments = try parser.parse(argsv)
			
			let archivePath = parsedArguments.get(archive) ?? ""
			let excludedFileExtensions = parsedArguments.get(excluded)
			
			let xml = try Converter().convert(archivePath, excludedFileExtensions: excludedFileExtensions)
			io.print(xml)
			
		} catch ArgumentParserError.expectedValue(let value) {
			io.print("Missing value for argument \(value).", to: .error)
		} catch ArgumentParserError.expectedArguments(_, let stringArray) {
			io.print("Missing arguments: \(stringArray.joined()).", to: .error)
		} catch {
			io.print(error.localizedDescription, to: .error)
		}
	}
	
}
