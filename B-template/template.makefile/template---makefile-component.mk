## +FHDR--------------------------------------------------------------------------------------------------------- ##
## -------------------------------------------------------------------------------------------------------------- ##
## Project ____________                                                                                           ##
## File name __________ makefile                                                                                  ##
## Creator ____________ miles.Yan                                                                                 ##
## Built Date _________ Aug-15-2025                                                                               ##
## Function ___________ Full Header template                                                                      ##
## Hierarchy __________                                                                                           ##
##   Parent ___________                                                                                           ##
##   Children _________                                                                                           ##
## Revision history ___ Date        Author            Description                                                 ##
##                  ___                                                                                           ##
## -FHDR--------------------------------------------------------------------------------------------------------- ##



# ======================================================================================
******************  有註解  ******************

help:  # <--- 定義 help 這個 target
  @printf "Available targets\n"  # 印出表頭
  @awk '/^[a-zA-Z\-\_0-9]+:/ { \      # 搜尋以 target 名稱開頭的行（例如 build:）
    helpMessage = match(lastLine, /^## (.*)/); \  # 如果前一行有以 ## 開頭的註解
    if (helpMessage) { \
      helpCommand = substr($$1, 0, index($$1, ":")-1); \  # 擷取 target 名稱
      helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \  # 擷取說明文字
      printf "%-15s %s\n", helpCommand, helpMessage; \  # 輸出格式化資訊
    } \
  } \
  { lastLine = $$0 }' $(MAKEFILE_LIST)  # 記住當前行，下一行用來檢查

******************  沒註解  ******************

help:
  @printf "Available targets\n"
  @awk '/^[a-zA-Z\-\_0-9]+:/ { \
    helpMessage = match(lastLine, /^## (.*)/); \
    if (helpMessage) { \
      helpCommand = substr($$1, 0, index($$1, ":")-1); \
      helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
      printf "%-15s %s\n", helpCommand, helpMessage; \
    } \
  } \
  { lastLine = $$0 }' $(MAKEFILE_LIST)  # 記住當前行，下一行用來檢查

  # ======================================================================================