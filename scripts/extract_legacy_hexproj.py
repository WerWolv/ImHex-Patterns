import json
import sys
from pathlib import Path

def extractData(projectName, jsonData, objectName, extension):
    if objectName in jsonData:
        with open(f"./{projectName}.{extension}", mode="w", encoding="utf-8") as output:
            output.write(jsonData[objectName])

def main():
    if len(sys.argv) != 2 or not str(sys.argv[1]).endswith(".hexproj"):
        print(f"Usage: {sys.argv[0]} <filename.hexproj>")
        exit(1)

    projectPath = sys.argv[1]
    with open(projectPath, mode="r", encoding="utf-8") as file:
        jsonData = json.loads(file.read())

        projectName = Path(projectPath).stem

        extractData(projectName, jsonData, "dataProcessor", "hexnode")
        extractData(projectName, jsonData, "pattern", "hexpat")
        
        if "bookmarks" in jsonData:
            with open(f"./{projectName}.hexbm", mode="w", encoding="utf-8") as output:
                jsonOutput = {}
                jsonOutput["bookmarks"] = jsonData["bookmarks"]

                output.write(json.dumps(jsonOutput, indent=4))

        if "filePath" in jsonData:
            print(f"Project file used file {jsonData['filePath']}")

if __name__ == "__main__":
    main()
