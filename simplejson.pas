unit SimpleJSON;

{$MODE DELPHI}{$H+}

interface

uses
  SysUtils, Classes, fpjson, jsonparser, Generics.Collections;

const
  JSON_DATE_FORMAT = 'yyyy-mm-dd"T"hh:nn:ss.zzz';

type
  // 定义 fpjson 类型别名，方便代码迁移
  TJSONObject = fpjson.TJSONObject;
  TJSONValue = fpjson.TJSONData;
  TJSONNumber = fpjson.TJSONNumber;
  TJSONString = fpjson.TJSONString;
  TJSONBool = fpjson.TJSONBoolean;
  TJSONNull = fpjson.TJSONNull;

  TJsonValueType = (jvtNull, jvtString, jvtNumber, jvtBoolean, jvtObject, jvtArray);

  // 新增：用于存储扁平化数据的结构
  TJsonFlatItem = record
    Path: string;         // 路径，如 "users[0].name"
    ValueType: TJsonValueType;
    Value: string;        // 统一转为字符串表示
  end;

  // 扁平化结果数组类型
  TJsonFlatItems = array of TJsonFlatItem;

  IJson = interface;
  IJsonArray = interface;

  IJsonArray = interface ['{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}']
    function GetCount: Integer;
    function GetS(Index: Integer): string;
    function GetI(Index: Integer): Integer;
    function GetL(Index: Integer): Int64;
    function GetF(Index: Integer): Double;
    function GetB(Index: Integer): Boolean;
    function GetD(Index: Integer): TDateTime;
    function GetO(Index: Integer): IJson;
    function GetA(Index: Integer): IJsonArray;
    function IsNull(Index: Integer): Boolean;
    function GetValueType(Index: Integer): TJsonValueType;
    function Add(const Value: string): IJsonArray; overload;
    function Add(Value: Integer): IJsonArray; overload;
    function Add(Value: Int64): IJsonArray; overload;
    function Add(Value: Double): IJsonArray; overload;
    function Add(Value: Boolean): IJsonArray; overload;
    function Add(Value: TDateTime): IJsonArray; overload;
    function AddNull: IJsonArray;
    function AddObject: IJson;
    function AddArray: IJsonArray;
    procedure Delete(Index: Integer);
    procedure Clear;
    function Clone: IJsonArray;
    function ToJSON: string;
    function Format: string;
    property Count: Integer read GetCount;
    property S[Index: Integer]: string read GetS;
    property I[Index: Integer]: Integer read GetI;
    property L[Index: Integer]: Int64 read GetL;
    property F[Index: Integer]: Double read GetF;
    property B[Index: Integer]: Boolean read GetB;
    property D[Index: Integer]: TDateTime read GetD;
    property O[Index: Integer]: IJson read GetO;
    property A[Index: Integer]: IJsonArray read GetA;
  end;

  IJson = interface ['{B2C3D4E5-F6A7-8901-BCDE-F12345678901}']
    function GetS(const Key: string): string;
    procedure SetS(const Key, Value: string);
    function GetI(const Key: string): Integer;
    procedure SetI(const Key: string; Value: Integer);
    function GetL(const Key: string): Int64;
    procedure SetL(const Key: string; Value: Int64);
    function GetF(const Key: string): Double;
    procedure SetF(const Key: string; Value: Double);
    function GetB(const Key: string): Boolean;
    procedure SetB(const Key: string; Value: Boolean);
    function GetD(const Key: string): TDateTime;
    procedure SetD(const Key: string; Value: TDateTime);
    function GetO(const Key: string): IJson;
    function GetA(const Key: string): IJsonArray;
    function GetPath(const Path: string): string;
    function IsNull(const Key: string): Boolean;
    procedure SetNull(const Key: string);
    function GetValueType(const Key: string): TJsonValueType;
    function TryGetS(const Key: string; out Value: string): Boolean;
    function TryGetI(const Key: string; out Value: Integer): Boolean;
    function TryGetL(const Key: string; out Value: Int64): Boolean;
    function TryGetF(const Key: string; out Value: Double): Boolean;
    function TryGetB(const Key: string; out Value: Boolean): Boolean;
    function TryGetD(const Key: string; out Value: TDateTime): Boolean;
    function TryGetO(const Key: string; out Value: IJson): Boolean;
    function TryGetA(const Key: string; out Value: IJsonArray): Boolean;
    function Contains(const Key: string): Boolean;
    procedure Remove(const Key: string);
    procedure Clear;
    function GetKeys: TArray<string>;
    function GetCount: Integer;
    function ToJSON: string;
    function Format: string;
    procedure SaveToFile(const FileName: string);
    function Clone: IJson;
    function Flatten: TJsonFlatItems; // 新增方法

    property S[const Key: string]: string read GetS write SetS;
    property I[const Key: string]: Integer read GetI write SetI;
    property L[const Key: string]: Int64 read GetL write SetL;
    property F[const Key: string]: Double read GetF write SetF;
    property B[const Key: string]: Boolean read GetB write SetB;
    property D[const Key: string]: TDateTime read GetD write SetD;
    property O[const Key: string]: IJson read GetO;
    property A[const Key: string]: IJsonArray read GetA;
    property Path[const Path: string]: string read GetPath;
    property Count: Integer read GetCount;
  end;

  TJsonArray = class;

  TJson = class(TInterfacedObject, IJson)
  private
    FObject: TJSONObject;
    FOwned: Boolean;
    function GetS(const Key: string): string;
    procedure SetS(const Key, Value: string);
    function GetI(const Key: string): Integer;
    procedure SetI(const Key: string; Value: Integer);
    function GetL(const Key: string): Int64;
    procedure SetL(const Key: string; Value: Int64);
    function GetF(const Key: string): Double;
    procedure SetF(const Key: string; Value: Double);
    function GetB(const Key: string): Boolean;
    procedure SetB(const Key: string; Value: Boolean);
    function GetD(const Key: string): TDateTime;
    procedure SetD(const Key: string; Value: TDateTime);
    function GetO(const Key: string): IJson;
    function GetA(const Key: string): IJsonArray;
    function GetPath(const Path: string): string;
  public
    constructor Create; overload;
    constructor Create(AObject: TJSONObject; AOwned: Boolean = True); overload;
    destructor Destroy; override;
    class function Parse(const JSONString: string): IJson; static;
    class function ParseFile(const FileName: string): IJson; static;
    class function LoadFromFile(const FileName: string): IJson; static;
    function IsNull(const Key: string): Boolean;
    procedure SetNull(const Key: string);
    function GetValueType(const Key: string): TJsonValueType;
    function TryGetS(const Key: string; out Value: string): Boolean;
    function TryGetI(const Key: string; out Value: Integer): Boolean;
    function TryGetL(const Key: string; out Value: Int64): Boolean;
    function TryGetF(const Key: string; out Value: Double): Boolean;
    function TryGetB(const Key: string; out Value: Boolean): Boolean;
    function TryGetD(const Key: string; out Value: TDateTime): Boolean;
    function TryGetO(const Key: string; out Value: IJson): Boolean;
    function TryGetA(const Key: string; out Value: IJsonArray): Boolean;
    function Contains(const Key: string): Boolean;
    procedure Remove(const Key: string);
    procedure Clear;
    function GetKeys: TArray<string>;
    function GetCount: Integer;
    function ToJSON: string;
    function Format: string;
    procedure SaveToFile(const FileName: string);
    function Clone: IJson;
    function Flatten: TJsonFlatItems;

    property S[const Key: string]: string read GetS write SetS;
    property I[const Key: string]: Integer read GetI write SetI;
    property L[const Key: string]: Int64 read GetL write SetL;
    property F[const Key: string]: Double read GetF write SetF;
    property B[const Key: string]: Boolean read GetB write SetB;
    property D[const Key: string]: TDateTime read GetD write SetD;
    property O[const Key: string]: IJson read GetO;
    property A[const Key: string]: IJsonArray read GetA;
    property Path[const Path: string]: string read GetPath;
    property Count: Integer read GetCount;
  end;

  TJsonArray = class(TInterfacedObject, IJsonArray)
  private
    FArray: fpjson.TJSONArray;
    FOwned: Boolean;
    FJsonWrappers: TObjectList<TJson>;
    FArrayWrappers: TObjectList<TJsonArray>;
    function GetCount: Integer;
    function GetS(Index: Integer): string;
    function GetI(Index: Integer): Integer;
    function GetL(Index: Integer): Int64;
    function GetF(Index: Integer): Double;
    function GetB(Index: Integer): Boolean;
    function GetD(Index: Integer): TDateTime;
    function GetO(Index: Integer): IJson;
    function GetA(Index: Integer): IJsonArray;
  public
    constructor Create; overload;
    constructor Create(AArray: fpjson.TJSONArray; AOwned: Boolean = True); overload;
    destructor Destroy; override;
    class function Parse(const JSONString: string): IJsonArray; static;
    function IsNull(Index: Integer): Boolean;
    function GetValueType(Index: Integer): TJsonValueType;
    function Add(const Value: string): IJsonArray; overload;
    function Add(Value: Integer): IJsonArray; overload;
    function Add(Value: Int64): IJsonArray; overload;
    function Add(Value: Double): IJsonArray; overload;
    function Add(Value: Boolean): IJsonArray; overload;
    function Add(Value: TDateTime): IJsonArray; overload;
    function AddNull: IJsonArray;
    function AddObject: IJson;
    function AddArray: IJsonArray;
    procedure Delete(Index: Integer);
    procedure Clear;
    function Clone: IJsonArray;
    function ToJSON: string;
    function Format: string;
    property Count: Integer read GetCount;
    property S[Index: Integer]: string read GetS;
    property I[Index: Integer]: Integer read GetI;
    property L[Index: Integer]: Int64 read GetL;
    property F[Index: Integer]: Double read GetF;
    property B[Index: Integer]: Boolean read GetB;
    property D[Index: Integer]: TDateTime read GetD;
    property O[Index: Integer]: IJson read GetO;
    property A[Index: Integer]: IJsonArray read GetA;
  end;

function TryParseJSONDateTime(const S: string; out Value: TDateTime): Boolean;

implementation

uses
  DateUtils, Character;

// 辅助：判断 fpjson 数据类型
function GetJsonValueType(Data: TJSONData): TJsonValueType;
begin
  if Data is TJSONNull then Result := jvtNull
  else if Data is TJSONString then Result := jvtString
  else if Data is TJSONNumber then Result := jvtNumber
  else if Data is TJSONBool then Result := jvtBoolean
  else if Data is TJSONObject then Result := jvtObject
  else if Data is fpjson.TJSONArray then Result := jvtArray
  else Result := jvtNull;
end;

// 自定义浮点数转字符串
function DoubleToJsonString(V: Double): string;
var
  FS: TFormatSettings;
begin
  FS := DefaultFormatSettings;
  FS.DecimalSeparator := '.';
  if (Abs(V) > 1E15) or (Abs(V) < 1E-15) then
    Result := FloatToStr(V, FS)
  else
  begin
    Result := FloatToStrF(V, ffFixed, 18, 15, FS);
    while (Length(Result) > 1) and (Result[Length(Result)] = '0') do
      Delete(Result, Length(Result), 1);
    if (Length(Result) > 1) and (Result[Length(Result)] = '.') then
      Delete(Result, Length(Result), 1);
  end;
end;

// 核心序列化逻辑
function JsonDataToString(Data: TJSONData; Indent: Integer; Formatted: Boolean): string;
var
  i: Integer;
  IndentStr, InnerIndentStr: string;
begin
  Result := '';
  if not Assigned(Data) then Exit;

  if Formatted then
  begin
    IndentStr := StringOfChar(' ', Indent * 2);
    InnerIndentStr := StringOfChar(' ', (Indent + 1) * 2);
  end
  else
  begin
    IndentStr := '';
    InnerIndentStr := '';
  end;

  if Data is TJSONObject then
  begin
    if Data.Count = 0 then
      Result := '{}'
    else
    begin
      Result := '{';
      if Formatted then Result := Result + LineEnding;
      for i := 0 to Data.Count - 1 do
      begin
        if Formatted then Result := Result + InnerIndentStr;
        Result := Result + '"' + TJSONObject(Data).Names[i] + '":';
        if Formatted then Result := Result + ' ';
        Result := Result + JsonDataToString(TJSONObject(Data).Items[i], Indent + 1, Formatted);
        if i < Data.Count - 1 then Result := Result + ',';
        if Formatted then Result := Result + LineEnding;
      end;
      if Formatted then Result := Result + IndentStr;
      Result := Result + '}';
    end;
  end
  else if Data is fpjson.TJSONArray then
  begin
    if Data.Count = 0 then
      Result := '[]'
    else
    begin
      Result := '[';
      if Formatted then Result := Result + LineEnding;
      for i := 0 to Data.Count - 1 do
      begin
        if Formatted then Result := Result + InnerIndentStr;
        Result := Result + JsonDataToString(Data.Items[i], Indent + 1, Formatted);
        if i < Data.Count - 1 then Result := Result + ',';
        if Formatted then Result := Result + LineEnding;
      end;
      if Formatted then Result := Result + IndentStr;
      Result := Result + ']';
    end;
  end
  else if Data is fpjson.TJSONFloatNumber then
    Result := DoubleToJsonString(Data.AsFloat)
  else
    Result := Data.AsJSON;
end;

function TryParseJSONDateTime(const S: string; out Value: TDateTime): Boolean;
var
  Year, Month, Day, Hour, Min, Sec, MSec: Word;
  DateStr, TimeStr: string;
  P, TempInt: Integer;
begin
  Result := False;
  Value := 0;
  if S = '' then Exit;

  DateStr := S;
  TimeStr := '';
  P := Pos('T', DateStr);
  if P > 0 then
  begin
    TimeStr := Copy(DateStr, P + 1, MaxInt);
    DateStr := Copy(DateStr, 1, P - 1);
  end;

  if (Length(DateStr) > 10) and CharInSet(DateStr[Length(DateStr) - 5], ['+', '-']) then
  begin
    DateStr := Copy(DateStr, 1, Length(DateStr) - 6);
    TimeStr := '';
  end;

  if (Length(TimeStr) > 1) and (TimeStr[Length(TimeStr)] = 'Z') then
    TimeStr := Copy(TimeStr, 1, Length(TimeStr) - 1);

  if Length(DateStr) >= 10 then
  begin
    if not TryStrToInt(Copy(DateStr, 1, 4), TempInt) then Exit;
    Year := TempInt;
    if not TryStrToInt(Copy(DateStr, 6, 2), TempInt) then Exit;
    Month := TempInt;
    if not TryStrToInt(Copy(DateStr, 9, 2), TempInt) then Exit;
    Day := TempInt;
    if (Year < 1) or (Year > 9999) then Exit;
    if (Month < 1) or (Month > 12) then Exit;
    if (Day < 1) or (Day > 31) then Exit;
  end
  else
    Exit;

  Hour := 0; Min := 0; Sec := 0; MSec := 0;
  if TimeStr <> '' then
  begin
    if Length(TimeStr) >= 2 then
      if TryStrToInt(Copy(TimeStr, 1, 2), TempInt) then Hour := TempInt;
    if Length(TimeStr) >= 5 then
      if TryStrToInt(Copy(TimeStr, 4, 2), TempInt) then Min := TempInt;
    if Length(TimeStr) >= 8 then
      if TryStrToInt(Copy(TimeStr, 7, 2), TempInt) then Sec := TempInt;
    if Length(TimeStr) >= 12 then
      if TryStrToInt(Copy(TimeStr, 10, 3), TempInt) then MSec := TempInt;
  end;

  try
    Value := EncodeDateTime(Year, Month, Day, Hour, Min, Sec, MSec);
    Result := True;
  except
    Result := False;
    Value := 0;
  end;
end;

{ TJson }

constructor TJson.Create;
begin
  inherited Create;
  FObject := TJSONObject.Create;
  FOwned := True;
end;

constructor TJson.Create(AObject: TJSONObject; AOwned: Boolean);
begin
  inherited Create;
  FObject := AObject;
  FOwned := AOwned;
end;

destructor TJson.Destroy;
begin
  if FOwned and Assigned(FObject) then
    FObject.Free;
  inherited;
end;

class function TJson.Parse(const JSONString: string): IJson;
var
  JVal: TJSONData;
begin
  try
    JVal := GetJSON(JSONString);
    if JVal is TJSONObject then
      Result := TJson.Create(TJSONObject(JVal), True)
    else
    begin
      JVal.Free;
      Result := nil;
    end;
  except
    Result := nil;
  end;
end;

class function TJson.ParseFile(const FileName: string): IJson;
var
  List: TStringList;
begin
  List := TStringList.Create;
  try
    List.LoadFromFile(FileName);
    Result := Parse(List.Text);
  finally
    List.Free;
  end;
end;

class function TJson.LoadFromFile(const FileName: string): IJson;
begin
  Result := ParseFile(FileName);
end;

function TJson.GetS(const Key: string): string;
var
  Val: TJSONData;
begin
  Result := '';
  if Assigned(FObject) then
  begin
    Val := FObject.Find(Key);
    if Assigned(Val) and not (Val is TJSONNull) then
      Result := Val.AsString;
  end;
end;

procedure TJson.SetS(const Key, Value: string);
begin
  if not Assigned(FObject) then FObject := TJSONObject.Create;
  FObject.Delete(Key);
  FObject.Add(Key, Value);
end;

function TJson.GetI(const Key: string): Integer;
var
  Val: TJSONData;
begin
  Result := 0;
  if Assigned(FObject) then
  begin
    Val := FObject.Find(Key);
    if Assigned(Val) then
    begin
      if Val is TJSONNumber then
        Result := TJSONNumber(Val).AsInteger
      else
        TryStrToInt(Val.AsString, Result);
    end;
  end;
end;

procedure TJson.SetI(const Key: string; Value: Integer);
begin
  if not Assigned(FObject) then FObject := TJSONObject.Create;
  FObject.Delete(Key);
  FObject.Add(Key, Value);
end;

function TJson.GetL(const Key: string): Int64;
var
  Val: TJSONData;
begin
  Result := 0;
  if Assigned(FObject) then
  begin
    Val := FObject.Find(Key);
    if Assigned(Val) then
    begin
      if Val is TJSONNumber then
        Result := TJSONNumber(Val).AsInt64
      else
        TryStrToInt64(Val.AsString, Result);
    end;
  end;
end;

procedure TJson.SetL(const Key: string; Value: Int64);
begin
  if not Assigned(FObject) then FObject := TJSONObject.Create;
  FObject.Delete(Key);
  FObject.Add(Key, Value);
end;

function TJson.GetF(const Key: string): Double;
var
  Val: TJSONData;
begin
  Result := 0.0;
  if Assigned(FObject) then
  begin
    Val := FObject.Find(Key);
    if Assigned(Val) then
    begin
      if Val is TJSONNumber then
        Result := TJSONNumber(Val).AsFloat
      else
        TryStrToFloat(Val.AsString, Result);
    end;
  end;
end;

procedure TJson.SetF(const Key: string; Value: Double);
begin
  if not Assigned(FObject) then FObject := TJSONObject.Create;
  FObject.Delete(Key);
  FObject.Add(Key, Value);
end;

function TJson.GetB(const Key: string): Boolean;
var
  Val: TJSONData;
begin
  Result := False;
  if Assigned(FObject) then
  begin
    Val := FObject.Find(Key);
    if Assigned(Val) then
    begin
      if Val is TJSONBoolean then
        Result := TJSONBoolean(Val).AsBoolean
      else
        Result := SameText(Val.AsString, 'true');
    end;
  end;
end;

procedure TJson.SetB(const Key: string; Value: Boolean);
begin
  if not Assigned(FObject) then FObject := TJSONObject.Create;
  FObject.Delete(Key);
  FObject.Add(Key, Value);
end;

function TJson.GetD(const Key: string): TDateTime;
var
  Val: TJSONData;
begin
  Result := 0;
  if Assigned(FObject) then
  begin
    Val := FObject.Find(Key);
    if Assigned(Val) then
      TryParseJSONDateTime(Val.AsString, Result);
  end;
end;

procedure TJson.SetD(const Key: string; Value: TDateTime);
begin
  if not Assigned(FObject) then FObject := TJSONObject.Create;
  FObject.Delete(Key);
  FObject.Add(Key, FormatDateTime(JSON_DATE_FORMAT, Value));
end;

function TJson.GetO(const Key: string): IJson;
var
  Val: TJSONData;
  NewObj: TJSONObject;
begin
  Result := nil;
  if not Assigned(FObject) then FObject := TJSONObject.Create;

  Val := FObject.Find(Key);
  if Assigned(Val) then
  begin
    if Val is TJSONObject then
      Result := TJson.Create(TJSONObject(Val), False);
  end
  else
  begin
    NewObj := TJSONObject.Create;
    FObject.Add(Key, NewObj);
    Result := TJson.Create(NewObj, False);
  end;
end;

function TJson.GetA(const Key: string): IJsonArray;
var
  Val: TJSONData;
  NewArr: fpjson.TJSONArray;
begin
  Result := nil;
  if not Assigned(FObject) then FObject := TJSONObject.Create;

  Val := FObject.Find(Key);
  if Assigned(Val) then
  begin
    if Val is fpjson.TJSONArray then
      Result := TJsonArray.Create(fpjson.TJSONArray(Val), False);
  end
  else
  begin
    NewArr := fpjson.TJSONArray.Create;
    FObject.Add(Key, NewArr);
    Result := TJsonArray.Create(NewArr, False);
  end;
end;

function TJson.GetPath(const Path: string): string;
var
  Parts: TArray<string>;
  CurrentValue: TJSONData;
  i, Index: Integer;
  Key: string;
begin
  Result := '';
  if not Assigned(FObject) then Exit;

  Parts := Path.Split(['.', '[', ']'], TStringSplitOptions.ExcludeEmpty);
  CurrentValue := FObject;

  for i := 0 to Length(Parts) - 1 do
  begin
    Key := Parts[i];
    if CurrentValue is TJSONObject then
    begin
      CurrentValue := TJSONObject(CurrentValue).Find(Key);
      if not Assigned(CurrentValue) then Exit;
    end
    else if CurrentValue is fpjson.TJSONArray then
    begin
      if TryStrToInt(Key, Index) and (Index >= 0) and (Index < fpjson.TJSONArray(CurrentValue).Count) then
        CurrentValue := fpjson.TJSONArray(CurrentValue).Items[Index]
      else
        Exit;
    end
    else
      Exit;
  end;

  if Assigned(CurrentValue) then
    Result := CurrentValue.AsString;
end;

function TJson.IsNull(const Key: string): Boolean;
var
  Val: TJSONData;
begin
  Result := False;
  if Assigned(FObject) then
  begin
    Val := FObject.Find(Key);
    Result := (Val is TJSONNull);
  end;
end;

procedure TJson.SetNull(const Key: string);
begin
  if not Assigned(FObject) then FObject := TJSONObject.Create;
  FObject.Delete(Key);
  FObject.Add(Key, TJSONNull.Create);
end;

function TJson.GetValueType(const Key: string): TJsonValueType;
var
  Val: TJSONData;
begin
  Result := jvtNull;
  if not Assigned(FObject) then Exit;
  Val := FObject.Find(Key);
  if not Assigned(Val) then Exit;
  Result := GetJsonValueType(Val);
end;

function TJson.TryGetS(const Key: string; out Value: string): Boolean;
var
  JSONValue: TJSONData;
begin
  Value := '';
  Result := Assigned(FObject);
  if Result then
  begin
    JSONValue := FObject.Find(Key);
    Result := Assigned(JSONValue) and not (JSONValue is TJSONNull);
    if Result then
      Value := JSONValue.AsString;
  end;
end;

function TJson.TryGetI(const Key: string; out Value: Integer): Boolean;
var
  JSONValue: TJSONData;
begin
  Value := 0;
  Result := Assigned(FObject);
  if Result then
  begin
    JSONValue := FObject.Find(Key);
    Result := Assigned(JSONValue) and not (JSONValue is TJSONNull);
    if Result then
    begin
      if JSONValue is TJSONNumber then
        Value := TJSONNumber(JSONValue).AsInteger
      else
        Result := TryStrToInt(JSONValue.AsString, Value);
    end;
  end;
end;

function TJson.TryGetL(const Key: string; out Value: Int64): Boolean;
var
  JSONValue: TJSONData;
begin
  Value := 0;
  Result := Assigned(FObject);
  if Result then
  begin
    JSONValue := FObject.Find(Key);
    Result := Assigned(JSONValue) and not (JSONValue is TJSONNull);
    if Result then
    begin
      if JSONValue is TJSONNumber then
        Value := TJSONNumber(JSONValue).AsInt64
      else
        Result := TryStrToInt64(JSONValue.AsString, Value);
    end;
  end;
end;

function TJson.TryGetF(const Key: string; out Value: Double): Boolean;
var
  JSONValue: TJSONData;
begin
  Value := 0.0;
  Result := Assigned(FObject);
  if Result then
  begin
    JSONValue := FObject.Find(Key);
    Result := Assigned(JSONValue) and not (JSONValue is TJSONNull);
    if Result then
    begin
      if JSONValue is TJSONNumber then
        Value := TJSONNumber(JSONValue).AsFloat
      else
        Result := TryStrToFloat(JSONValue.AsString, Value);
    end;
  end;
end;

function TJson.TryGetB(const Key: string; out Value: Boolean): Boolean;
var
  JSONValue: TJSONData;
begin
  Value := False;
  Result := Assigned(FObject);
  if Result then
  begin
    JSONValue := FObject.Find(Key);
    Result := Assigned(JSONValue) and not (JSONValue is TJSONNull);
    if Result then
    begin
      if JSONValue is TJSONBoolean then
        Value := TJSONBoolean(JSONValue).AsBoolean
      else
        Value := SameText(JSONValue.AsString, 'true');
    end;
  end;
end;

function TJson.TryGetD(const Key: string; out Value: TDateTime): Boolean;
var
  JSONValue: TJSONData;
begin
  Value := 0;
  Result := Assigned(FObject);
  if Result then
  begin
    JSONValue := FObject.Find(Key);
    Result := Assigned(JSONValue) and not (JSONValue is TJSONNull);
    if Result then
      Result := TryParseJSONDateTime(JSONValue.AsString, Value);
  end;
end;

function TJson.TryGetO(const Key: string; out Value: IJson): Boolean;
var
  JSONValue: TJSONData;
begin
  Value := nil;
  Result := Assigned(FObject);
  if Result then
  begin
    JSONValue := FObject.Find(Key);
    Result := Assigned(JSONValue) and (JSONValue is TJSONObject);
    if Result then
      Value := TJson.Create(TJSONObject(JSONValue), False);
  end;
end;

function TJson.TryGetA(const Key: string; out Value: IJsonArray): Boolean;
var
  JSONValue: TJSONData;
begin
  Value := nil;
  Result := Assigned(FObject);
  if Result then
  begin
    JSONValue := FObject.Find(Key);
    Result := Assigned(JSONValue) and (JSONValue is fpjson.TJSONArray);
    if Result then
      Value := TJsonArray.Create(fpjson.TJSONArray(JSONValue), False);
  end;
end;

function TJson.Contains(const Key: string): Boolean;
begin
  Result := Assigned(FObject) and Assigned(FObject.Find(Key));
end;

procedure TJson.Remove(const Key: string);
begin
  if Assigned(FObject) then
    FObject.Delete(Key);
end;

procedure TJson.Clear;
begin
  if Assigned(FObject) then
    FreeAndNil(FObject);
  FObject := TJSONObject.Create;
end;

function TJson.GetKeys: TArray<string>;
var
  i: Integer;
begin
  SetLength(Result, 0);
  if not Assigned(FObject) then Exit;
  SetLength(Result, FObject.Count);
  for i := 0 to FObject.Count - 1 do
    Result[i] := FObject.Names[i];
end;

function TJson.GetCount: Integer;
begin
  if Assigned(FObject) then
    Result := FObject.Count
  else
    Result := 0;
end;

function TJson.ToJSON: string;
begin
  if Assigned(FObject) then
    Result := JsonDataToString(FObject, 0, False)
  else
    Result := '{}';
end;

function TJson.Format: string;
begin
  if Assigned(FObject) then
    Result := JsonDataToString(FObject, 0, True)
  else
    Result := '{}';
end;

procedure TJson.SaveToFile(const FileName: string);
var
  List: TStringList;
begin
  List := TStringList.Create;
  try
    List.Text := Format;
    List.SaveToFile(FileName);
  finally
    List.Free;
  end;
end;

function TJson.Clone: IJson;
begin
  if Assigned(FObject) then
    Result := TJson.Parse(ToJSON)
  else
    Result := TJson.Create;
end;

// --- Flatten 实现 ---
function TJson.Flatten: TJsonFlatItems;
var
  List: TList<TJsonFlatItem>;

  procedure Collect(Node: TJSONData; const CurrentPath: string);
  var
    i: Integer;
    ChildPath: string;
    Item: TJsonFlatItem;
  begin
    if not Assigned(Node) then Exit;

    if Node is TJSONObject then
    begin
      for i := 0 to Node.Count - 1 do
      begin
        if CurrentPath = '' then
          ChildPath := TJSONObject(Node).Names[i]
        else
          ChildPath := CurrentPath + '.' + TJSONObject(Node).Names[i];
        Collect(Node.Items[i], ChildPath);
      end;
    end
    else if Node is fpjson.TJSONArray then
    begin
      for i := 0 to Node.Count - 1 do
      begin
        ChildPath := CurrentPath + '[' + IntToStr(i) + ']';
        Collect(Node.Items[i], ChildPath);
      end;
    end
    else
    begin
      Item.Path := CurrentPath;
      Item.ValueType := GetJsonValueType(Node);
      if Node is fpjson.TJSONFloatNumber then
        Item.Value := DoubleToJsonString(Node.AsFloat)
      else
        Item.Value := Node.AsString;
      List.Add(Item);
    end;
  end;

var
  i: Integer;
begin
  List := TList<TJsonFlatItem>.Create;
  try
    if Assigned(FObject) then
      Collect(FObject, '');
    SetLength(Result, List.Count);
    for i := 0 to List.Count - 1 do
      Result[i] := List[i];
  finally
    List.Free;
  end;
end;

{ TJsonArray }

constructor TJsonArray.Create;
begin
  inherited Create;
  FArray := fpjson.TJSONArray.Create;
  FOwned := True;
  FJsonWrappers := TObjectList<TJson>.Create(False);
  FArrayWrappers := TObjectList<TJsonArray>.Create(False);
end;

constructor TJsonArray.Create(AArray: fpjson.TJSONArray; AOwned: Boolean);
begin
  inherited Create;
  FArray := AArray;
  FOwned := AOwned;
  FJsonWrappers := TObjectList<TJson>.Create(False);
  FArrayWrappers := TObjectList<TJsonArray>.Create(False);
end;

destructor TJsonArray.Destroy;
begin
  FJsonWrappers.Free;
  FArrayWrappers.Free;
  if FOwned and Assigned(FArray) then
    FArray.Free;
  inherited;
end;

class function TJsonArray.Parse(const JSONString: string): IJsonArray;
var
  JVal: TJSONData;
begin
  try
    JVal := GetJSON(JSONString);
    if JVal is fpjson.TJSONArray then
      Result := TJsonArray.Create(fpjson.TJSONArray(JVal), True)
    else
    begin
      JVal.Free;
      Result := nil;
    end;
  except
    Result := nil;
  end;
end;

function TJsonArray.GetCount: Integer;
begin
  if Assigned(FArray) then
    Result := FArray.Count
  else
    Result := 0;
end;

function TJsonArray.GetS(Index: Integer): string;
begin
  Result := '';
  if Assigned(FArray) and (Index >= 0) and (Index < FArray.Count) then
    Result := FArray.Strings[Index];
end;

function TJsonArray.GetI(Index: Integer): Integer;
begin
  Result := 0;
  if Assigned(FArray) and (Index >= 0) and (Index < FArray.Count) then
    Result := FArray.Integers[Index];
end;

function TJsonArray.GetL(Index: Integer): Int64;
begin
  Result := 0;
  if Assigned(FArray) and (Index >= 0) and (Index < FArray.Count) then
    Result := FArray.Integers[Index];
end;

function TJsonArray.GetF(Index: Integer): Double;
begin
  Result := 0.0;
  if Assigned(FArray) and (Index >= 0) and (Index < FArray.Count) then
    Result := FArray.Floats[Index];
end;

function TJsonArray.GetB(Index: Integer): Boolean;
begin
  Result := False;
  if Assigned(FArray) and (Index >= 0) and (Index < FArray.Count) then
    Result := FArray.Booleans[Index];
end;

function TJsonArray.GetD(Index: Integer): TDateTime;
var
  StrVal: string;
begin
  Result := 0;
  if Assigned(FArray) and (Index >= 0) and (Index < FArray.Count) then
  begin
    StrVal := FArray.Strings[Index];
    TryParseJSONDateTime(StrVal, Result);
  end;
end;

function TJsonArray.GetO(Index: Integer): IJson;
var
  Val: TJSONData;
  Json: TJson;
begin
  Result := nil;
  if Assigned(FArray) and (Index >= 0) and (Index < FArray.Count) then
  begin
    Val := FArray.Items[Index];
    if Val is TJSONObject then
    begin
      Json := TJson.Create(TJSONObject(Val), False);
      FJsonWrappers.Add(Json);
      Result := Json;
    end;
  end;
end;

function TJsonArray.GetA(Index: Integer): IJsonArray;
var
  Val: TJSONData;
  Arr: TJsonArray;
begin
  Result := nil;
  if Assigned(FArray) and (Index >= 0) and (Index < FArray.Count) then
  begin
    Val := FArray.Items[Index];
    if Val is fpjson.TJSONArray then
    begin
      Arr := TJsonArray.Create(fpjson.TJSONArray(Val), False);
      FArrayWrappers.Add(Arr);
      Result := Arr;
    end;
  end;
end;

function TJsonArray.IsNull(Index: Integer): Boolean;
begin
  Result := False;
  if Assigned(FArray) and (Index >= 0) and (Index < FArray.Count) then
    Result := FArray.Items[Index] is TJSONNull;
end;

function TJsonArray.GetValueType(Index: Integer): TJsonValueType;
var
  Val: TJSONData;
begin
  Result := jvtNull;
  if not Assigned(FArray) or (Index < 0) or (Index >= FArray.Count) then Exit;
  Val := FArray.Items[Index];
  Result := GetJsonValueType(Val);
end;

function TJsonArray.Add(const Value: string): IJsonArray;
begin
  if not Assigned(FArray) then FArray := fpjson.TJSONArray.Create;
  FArray.Add(Value);
  Result := Self;
end;

function TJsonArray.Add(Value: Integer): IJsonArray;
begin
  if not Assigned(FArray) then FArray := fpjson.TJSONArray.Create;
  FArray.Add(Value);
  Result := Self;
end;

function TJsonArray.Add(Value: Int64): IJsonArray;
begin
  if not Assigned(FArray) then FArray := fpjson.TJSONArray.Create;
  FArray.Add(Value);
  Result := Self;
end;

function TJsonArray.Add(Value: Double): IJsonArray;
begin
  if not Assigned(FArray) then FArray := fpjson.TJSONArray.Create;
  FArray.Add(Value);
  Result := Self;
end;

function TJsonArray.Add(Value: Boolean): IJsonArray;
begin
  if not Assigned(FArray) then FArray := fpjson.TJSONArray.Create;
  FArray.Add(Value);
  Result := Self;
end;

function TJsonArray.Add(Value: TDateTime): IJsonArray;
begin
  if not Assigned(FArray) then FArray := fpjson.TJSONArray.Create;
  FArray.Add(FormatDateTime(JSON_DATE_FORMAT, Value));
  Result := Self;
end;

function TJsonArray.AddNull: IJsonArray;
begin
  if not Assigned(FArray) then FArray := fpjson.TJSONArray.Create;
  FArray.Add(TJSONNull.Create);
  Result := Self;
end;

function TJsonArray.AddObject: IJson;
var
  NewObj: TJSONObject;
  Json: TJson;
begin
  if not Assigned(FArray) then FArray := fpjson.TJSONArray.Create;
  NewObj := TJSONObject.Create;
  FArray.Add(NewObj);
  Json := TJson.Create(NewObj, False);
  FJsonWrappers.Add(Json);
  Result := Json;
end;

function TJsonArray.AddArray: IJsonArray;
var
  NewArr: fpjson.TJSONArray;
  Arr: TJsonArray;
begin
  if not Assigned(FArray) then FArray := fpjson.TJSONArray.Create;
  NewArr := fpjson.TJSONArray.Create;
  FArray.Add(NewArr);
  Arr := TJsonArray.Create(NewArr, False);
  FArrayWrappers.Add(Arr);
  Result := Arr;
end;

procedure TJsonArray.Delete(Index: Integer);
begin
  if Assigned(FArray) and (Index >= 0) and (Index < FArray.Count) then
    FArray.Delete(Index);
end;

procedure TJsonArray.Clear;
begin
  if Assigned(FArray) then
    FreeAndNil(FArray);
  FArray := fpjson.TJSONArray.Create;
  FJsonWrappers.Clear;
  FArrayWrappers.Clear;
end;

function TJsonArray.Clone: IJsonArray;
begin
  if Assigned(FArray) then
    Result := TJsonArray.Parse(ToJSON)
  else
    Result := TJsonArray.Create;
end;

function TJsonArray.ToJSON: string;
begin
  if Assigned(FArray) then
    Result := JsonDataToString(FArray, 0, False)
  else
    Result := '[]';
end;

function TJsonArray.Format: string;
begin
  if Assigned(FArray) then
    Result := JsonDataToString(FArray, 0, True)
  else
    Result := '[]';
end;

end.

