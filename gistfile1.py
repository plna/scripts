from pydriller import RepositoryMining
import re
import base64

foundSet = set()
for commit in RepositoryMining('./').traverse_commits():
  for mod in commit.modifications:
    if mod.source_code_before != None:
      regex = re.findall(r"<text encoding=\"base64\">[^>]+</text>", mod.source_code_before)
      for result in regex:
        based = str(base64.b64decode(result[len("<text encoding='base64'>"):-len("</text>")]))
        if based not in foundSet:
          print(based)
          foundSet.add(based + "\n")