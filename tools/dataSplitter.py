import csv
import sys
import os

ROW_LIMIT = 100000

def main():
  inputFile = sys.argv[1]
  print "Reading from " + inputFile

  inputPath, inputFileName = os.path.split(inputFile)

  outDirectory = inputPath + '/' + inputFileName.split(".")[0] + "-split"

  if not os.path.exists(outDirectory):
    os.makedirs(outDirectory)

  # Open new file
  with open(inputFile, 'rU') as inputData:
    csvData = csv.reader(inputData)

    rowCount = 0
    saveCount = 0
    rowsToSave = []
    for i, row in enumerate(csvData):
      rowCount += 1
      rowsToSave.append(row)

      if rowCount >= ROW_LIMIT:
        saveCount += 1

        saveRows(outDirectory + "/" + inputFileName.split(".")[0] + "-" + str(saveCount) + ".csv", rowsToSave)

        rowsToSave = []
        rowCount = 0

    saveCount += 1
    saveRows(outDirectory + "/" + inputFileName.split(".")[0] + "-" + str(saveCount) + ".csv", rowsToSave)


def saveRows(outputFileName, data):
  with open(outputFileName, 'w+') as outputFile:
    writer = csv.writer(outputFile)
    writer.writerows(data)


if __name__ == "__main__":
  main()
