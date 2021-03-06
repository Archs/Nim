# bug #1744

import macros

type
  SuiteTest = object
    suiteName: string
    suiteDesc: string
    testName: string
    testDesc: string
    testBlock: PNimrodNode

proc buildSuiteContents(suiteName, suiteDesc, suiteBloc: PNimrodNode): tuple[tests: seq[SuiteTest]]  {.compileTime.} =
  var
    tests:seq[SuiteTest] = @[]

  for child in suiteBloc.children():
    case $child[0].ident:
    of "test":

      var testObj = SuiteTest()
      if suiteName.kind == nnkNilLit:
        testObj.suiteName = nil
      else:
        testObj.suiteName = $suiteName
      if suiteDesc.kind == nnkNilLit:
        testObj.suiteDesc = nil
      else:
        testObj.suiteDesc = suiteDesc.strVal
      testObj.testName = $child[1] # should not ever be nil
      if child[2].kind == nnkNilLit:
        testObj.testDesc = nil
      else:
        testObj.testDesc = child[2].strVal
      testObj.testBlock = child[1]

      tests.add(testObj)

    else:
      discard

  return (tests: tests)
 
macro suite(suiteName, suiteDesc: expr, suiteBloc: stmt): stmt {.immediate.} =
  let contents = buildSuiteContents(suiteName, suiteDesc, suiteBloc)

# Test above
suite basics, "Description of such":
  test(t5, nil):
    assert false
