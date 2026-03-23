# SimpleJSON

一个简洁易用的 Delphi JSON 封装库，基于 `System.JSON` 单元封装，提供更直观的 API。

## 特性

- **类型化属性访问** - 使用 `S/I/F/B` 属性直接读写不同类型值
- **链式调用** - 支持流式 API，代码更简洁
- **自动内存管理** - 基于接口引用计数，无需手动释放
- **嵌套对象支持** - 轻松创建和访问多层嵌套结构
- **路径访问** - 支持 `info.city`、`users.0.name` 格式的路径访问
- **零依赖** - 仅依赖 Delphi 标准库

## 快速开始

### 基本用法

```delphi
uses
  SimpleJSON;

var
  Json: IJson;
begin
  // 创建对象
  Json := TJson.Create;
  
  // 设置值
  Json.S['name'] := '张三';
  Json.I['age'] := 25;
  Json.F['salary'] := 8500.50;
  Json.B['active'] := True;
  
  // 读取值
  Writeln(Json.S['name']);      // 输出: 张三
  Writeln(IntToStr(Json.I['age']));  // 输出: 25
  
  // 无需 Free，接口自动管理内存
end;
```

### 解析 JSON 字符串

```delphi
var
  Json: IJson;
begin
  Json := TJson.Parse('{"id":1001,"name":"Delphi","price":199.99}');
  if Assigned(Json) then
    Writeln(Json.S['name']);  // 输出: Delphi
end;
```

### 嵌套对象

```delphi
var
  Json: IJson;
begin
  Json := TJson.Create;
  
  // 自动创建嵌套对象
  Json.O['address'].S['city'] := '北京';
  Json.O['address'].S['zip'] := '100001';
  
  // 访问嵌套值
  Writeln(Json.O['address'].S['city']);  // 输出: 北京
end;
```

### 数组操作

```delphi
var
  Json: IJson;
  i: Integer;
begin
  Json := TJson.Create;
  
  // 链式添加数组元素
  Json.A['fruits']
    .Add('苹果')
    .Add('香蕉')
    .Add('橙子');
  
  // 遍历数组
  for i := 0 to Json.A['fruits'].Count - 1 do
    Writeln(Json.A['fruits'].S[i]);
end;
```

### 对象数组

```delphi
var
  Json: IJson;
begin
  Json := TJson.Create;
  
  // 添加对象到数组
  Json.A['users'].AddObject.S['name'] := '用户1';
  Json.A['users'].O[0].I['age'] := 20;
  
  Json.A['users'].AddObject.S['name'] := '用户2';
  Json.A['users'].O[1].I['age'] := 25;
end;
```

### 路径访问

```delphi
var
  Json: IJson;
begin
  Json := TJson.Create;
  Json.S['name'] := '测试';
  Json.O['info'].S['city'] := '上海';
  Json.A['tags'].Add('tag1').Add('tag2');
  
  // 使用路径访问
  Writeln(Json.Path['name']);        // 输出: 测试
  Writeln(Json.Path['info.city']);   // 输出: 上海
  Writeln(Json.Path['tags.0']);      // 输出: tag1
end;
```

## API 参考

### IJson 接口

| 属性/方法 | 说明 |
|-----------|------|
| `S[Key]` | 字符串类型读写 |
| `I[Key]` | 整数类型读写 |
| `F[Key]` | 浮点数类型读写 |
| `B[Key]` | 布尔类型读写 |
| `O[Key]` | 获取嵌套对象 |
| `A[Key]` | 获取数组 |
| `Path[Path]` | 路径方式访问值 |
| `Contains(Key)` | 检查键是否存在 |
| `Remove(Key)` | 删除指定键 |
| `Clear` | 清空对象 |
| `GetKeys` | 获取所有键名 |
| `Count` | 获取键数量 |
| `ToJSON` | 输出紧凑 JSON 字符串 |
| `Format` | 输出格式化 JSON 字符串 |

### IJsonArray 接口

| 属性/方法 | 说明 |
|-----------|------|
| `S[Index]` | 获取字符串元素 |
| `I[Index]` | 获取整数元素 |
| `F[Index]` | 获取浮点数元素 |
| `B[Index]` | 获取布尔元素 |
| `O[Index]` | 获取对象元素 |
| `Add(Value)` | 添加元素，返回 Self 支持链式调用 |
| `AddObject` | 添加对象并返回 |
| `AddArray` | 添加数组并返回 |
| `Delete(Index)` | 删除指定位置元素 |
| `Clear` | 清空数组 |
| `Count` | 获取元素数量 |
| `ToJSON` | 输出紧凑 JSON 字符串 |
| `Format` | 输出格式化 JSON 字符串 |

### 类方法

| 方法 | 说明 |
|------|------|
| `TJson.Create` | 创建空 JSON 对象 |
| `TJson.Parse(String)` | 从字符串解析 JSON |
| `TJson.ParseFile(FileName)` | 从文件解析 JSON |
| `TJsonArray.Create` | 创建空 JSON 数组 |
| `TJsonArray.Parse(String)` | 从字符串解析 JSON 数组 |

## 与原生 System.JSON 对比

### 原生写法

```delphi
var
  Obj: TJSONObject;
begin
  Obj := TJSONObject.Create;
  try
    Obj.AddPair('name', TJSONString.Create('张三'));
    Obj.AddPair('age', TJSONNumber.Create(25));
    Writeln(Obj.GetValue<string>('name'));
  finally
    Obj.Free;
  end;
end;
```

### SimpleJSON 写法

```delphi
var
  Json: IJson;
begin
  Json := TJson.Create;
  Json.S['name'] := '张三';
  Json.I['age'] := 25;
  Writeln(Json.S['name']);
  // 无需 Free
end;
```

## 文件结构

```
jsontest/
├── SimpleJSON.pas        # 核心封装单元
├── SimpleJSONDemo.dpr    # 演示程序
└── README.md             # 本文档
```

## 编译要求

- Delphi 10.4 Sydney 或更高版本
- 支持 Win32/Win64 平台

## 编译方法

```bash
dcc32 SimpleJSONDemo.dpr
```

## 许可证

MIT License
