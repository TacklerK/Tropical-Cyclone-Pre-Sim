#install.packages("SHAPforxgboost", repos = "https://mirrors.ustc.edu.cn/CRAN/")
library(openxlsx)
library(xgboost)
library(ggplot2)
library(caret)
library(shapper)
library(SHAPforxgboost)


# 读样本
sample <- read.csv("E:/桌面/模拟路径处理/陆地/样本/LandData(terrain).csv")
sample <- sample[, c(14:55)]
for (i in c(5:8)) {
  sampledata <- sample[, c(1,4:10,(10+i),(18+i),(26+i),(34+i))]#无气压
  colnames(sampledata)[12]<- "meanrainfall"
  #划分训练集与测试集
  set.seed(123)
  train <- sample(nrow(sampledata), nrow(sampledata) * 0.7)
  rain_train <- sampledata[train,]
  rain_test <- sampledata[-train,]
  #训练样本
  target <- rain_train$meanrainfall
  features <-
    rain_train[,!colnames(rain_train) %in% c("meanrainfall")]
  features <- as.matrix(features)#将特征变量转换为矩阵
  model <- xgboost(
    data = features,
    label = target,
    nrounds = 500,
    objective = "reg:linear",
    early_stopping_rounds = 5,
    max_depth = 12,
    #树的最大深度，默认值为6，合理的设置可以防止过拟合。
    eta = 0.1,
    #学习率
    gamma = 0.3,
    colsample_bytree = 1,
    #构建弱学习器时，对特征随机采样的比例，默认值为1。
    min_child_weight = 1,
    #孩子节点中最小的样本权重和
    subsample = 0.6
  )
  shap_values <- shap.values(xgb_model = model, X_train = features)
  shap_long <- shap.prep(xgb_model = model, X_train = features)
  shap_long <- shap.prep(shap_contrib = shap_values$shap_score, X_train =features)
  shap.plot.summary(shap_long)
  write.csv(shap_long,"E:/桌面/模拟文件/论文图/SHAP/Land.csv")
  
  modelsave <-
    paste("E:/桌面/模拟路径处理/陆地/模拟结果/模型迭代500/模型",
          as.character(i),
          ".RData",
          sep = "")
  save(model, file = modelsave)
  #预测
  predictions <- predict(model, newdata = features)
  mainname <- paste(as.character(i), "训练集", sep = "")
  plot(
    rain_train$meanrainfall,
    predictions,
    main = mainname,
    xlab = 'rainfall (mm)',
    ylab = 'Predict'
  )
  trainline <- lm(predictions ~ rain_train$meanrainfall)
  abline(trainline, col = "black")
  abline(1, 1, col = "firebrick")
  
  #########保存结果
  xgbsummary <-
    capture.output(defaultSummary(data.frame(
      obs = rain_train$meanrainfall, pred = predictions
    )))
  Train <- cbind(rain_train$meanrainfall, predictions)
  datasavepath <- paste("E:/桌面/模拟路径处理/陆地/模拟结果/模型迭代500/","训练集结果",as.character(i),".csv",sep="")
  write.csv(Train, file = datasavepath)
  summary_savepath <- paste("E:/桌面/模拟路径处理/陆地/模拟结果/模型迭代500/","训练集精度",as.character(i),".csv",sep="")
  write.csv(xgbsummary, file = summary_savepath)
  
  
  #测试集
  testfea <- rain_test[,!colnames(rain_test) %in% c("meanrainfall")]
  testpred <- predict(model, newdata = as.matrix(testfea))
  mainname <- paste(as.character(i), "测试集", sep = "")
  plot(
    rain_test$meanrainfall,
    testpred,
    main = mainname,
    xlab = 'rainfall (mm)',
    ylab = 'Predict',
    ylim = c(0, 100),
    xlim = c(0, 100)
  )
  trainline <- lm(predictions ~ rain_train$meanrainfall)
  abline(trainline, col = "black")
  abline(1, 1, col = "firebrick")
  # testrmse <- RMSE(rain_test$meanrainfall,testpred)
  # testr2 <- R2(rain_test$meanrainfall,testpred)
  # testmae <- MAE(rain_test$meanrainfall,testpred)
  
  #########保存结果
 Test <- cbind(rain_test$meanrainfall, testpred)
  savepath <- paste("E:/桌面/模拟路径处理/陆地/模拟结果/模型迭代500/","测试集结果",as.character(i),".csv",sep="")
  write.csv(Test, file = savepath)
  xgbsummary <- capture.output(defaultSummary(data.frame(obs=rain_test$meanrainfall,pred=testpred)))
  summary_savepath <- paste("E:/桌面/模拟路径处理/陆地/模拟结果/模型迭代500/","测试集精度",as.character(i),".csv",sep="")
  write.csv(xgbsummary, file = summary_savepath)
  
}

