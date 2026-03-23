unit SimpleJSON;

interface

uses
  System.SysUtils, System.Classes, System.JSON, System.Generics.Collections;

const
  JSON_DATE_FORMAT = 'yyyy-mm-dd"T"hh:nn:ss.zzz';
  JSON_DATE_FORMAT_SHORT = 'yyyy-mm-dd';

type
  IJson = interface;

  IJsonArray = interface
    ['{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}']
    function GetCount: Integer;
    function GetItem(Index: Integer): IJson;
    function GetO(Index: Integer): IJson;
    function GetS(Index: Integer): string;
    function GetI(Index: Integer): Integer;
    function GetF(Index: Integer): Double;
    function GetB(Index: Integer): Boolean;
    function GetD(Index: Integer): TDateTime;
    
    function Add(const Value: string): IJsonArray; overload;
    function Add(Value: Integer): IJsonArray; overload;
    function Add(Value: Double): IJsonArray; overload;
    function Add(Value: Boolean): IJsonArray; overload;
    function Add(Value: TDateTime): IJsonArray; overload;
    function AddObject: IJson;
    function AddArray: IJsonArray;
    procedure Delete(Index: Integer);
    procedure Clear;
    
    function ToJSON: string;
    function Format: string;
    
    property Count: Integer read GetCount;
    property Items[Index: Integer]: IJson read GetItem;
    property O[Index: Integer]: IJson read GetO;
    property S[Index: Integer]: string read GetS;
    property I[Index: Integer]: Integer read GetI;
    property F[Index: Integer]: Double read GetF;
    property B[Index: Integer]: Boolean read GetB;
    property D[Index: Integer]: TDateTime read GetD;
  end;

  IJson = interface
    ['{B2C3D4E5-F6A7-8901-BCDE-F12345678901}']
    function GetS(const Key: string): string;
    procedure SetS(const Key, Value: string);
    function GetI(const Key: string): Integer;
    procedure SetI(const Key: string; Value: Integer);
    function GetF(const Key: string): Double;
    procedure SetF(const Key: string; Value: Double);
    function GetB(const Key: string): Boolean;
    procedure SetB(const Key: string; Value: Boolean);
    function GetD(const Key: string): TDateTime;
    procedure SetD(const Key: string; Value: TDateTime);
    function GetO(const Key: string): IJson;
    function GetA(const Key: string): IJsonArray;
    function GetPath(const Path: string): string;
    
    function Contains(const Key: string): Boolean;
    procedure Remove(const Key: string);
    procedure Clear;
    function GetKeys: TArray<string>;
    function GetCount: Integer;
    
    function ToJSON: string;
    function Format: string;
    
    property S[const Key: string]: string read GetS write SetS;
    property I[const Key: string]: Integer read GetI write SetI;
    property F[const Key: string]: Double read GetF write SetF;
    property B[const Key: string]: Boolean read GetB write SetB;
    property D[const Key: string]: TDateTime read GetD write SetD;
    property O[const Key: string]: IJson read GetO;
    property A[const Key: string]: IJsonArray read GetA;
    property Path[const Path: string]: string read GetPath;
    property Count: Integer read GetCount;
  end;

  TSimpleJsonArray = class;

  TSimpleJson = class(TInterfacedObject, IJson)
  private
    FObject: System.JSON.TJSONObject;
    FOwned: Boolean;
    function GetS(const Key: string): string;
    procedure SetS(const Key, Value: string);
    function GetI(const Key: string): Integer;
    procedure SetI(const Key: string; Value: Integer);
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
    constructor Create(AObject: System.JSON.TJSONObject; AOwned: Boolean = True); overload;
    destructor Destroy; override;
    
    class function Parse(const JSONString: string): IJson; static;
    class function ParseFile(const FileName: string): IJson; static;
    
    function Contains(const Key: string): Boolean;
    procedure Remove(const Key: string);
    procedure Clear;
    function GetKeys: TArray<string>;
    function GetCount: Integer;
    
    function ToJSON: string;
    function Format: string;
    
    property S[const Key: string]: string read GetS write SetS;
    property I[const Key: string]: Integer read GetI write SetI;
    property F[const Key: string]: Double read GetF write SetF;
    property B[const Key: string]: Boolean read GetB write SetB;
    property D[const Key: string]: TDateTime read GetD write SetD;
    property O[const Key: string]: IJson read GetO;
    property A[const Key: string]: IJsonArray read GetA;
    property Path[const Path: string]: string read GetPath;
    property Count: Integer read GetCount;
  end;

  TSimpleJsonArray = class(TInterfacedObject, IJsonArray)
  private
    FArray: System.JSON.TJSONArray;
    FOwned: Boolean;
    FJsonWrappers: TObjectList<TSimpleJson>;
    FArrayWrappers: TObjectList<TSimpleJsonArray>;
    function GetCount: Integer;
    function GetItem(Index: Integer): IJson;
    function GetO(Index: Integer): IJson;
    function GetS(Index: Integer): string;
    function GetI(Index: Integer): Integer;
    function GetF(Index: Integer): Double;
    function GetB(Index: Integer): Boolean;
    function GetD(Index: Integer): TDateTime;
  public
    constructor Create; overload;
    constructor Create(AArray: System.JSON.TJSONArray; AOwned: Boolean = True); overload;
    destructor Destroy; override;
    
    class function Parse(const JSONString: string): IJsonArray; static;
    
    function Add(const Value: string): IJsonArray; overload;
    function Add(Value: Integer): IJsonArray; overload;
    function Add(Value: Double): IJsonArray; overload;
    function Add(Value: Boolean): IJsonArray; overload;
    function Add(Value: TDateTime): IJsonArray; overload;
    function AddObject: IJson;
    function AddArray: IJsonArray;
    procedure Delete(Index: Integer);
    procedure Clear;
    
    function ToJSON: string;
    function Format: string;
    
    property Count: Integer read GetCount;
    property Items[Index: Integer]: IJson read GetItem;
    property O[Index: Integer]: IJson read GetO;
    property S[Index: Integer]: string read GetS;
    property I[Index: Integer]: Integer read GetI;
    property F[Index: Integer]: Double read GetF;
    property B[Index: Integer]: Boolean read GetB;
    property D[Index: Integer]: TDateTime read GetD;
  end;

  TJson = TSimpleJson;
  TJsonArray = TSimpleJsonArray;

function TryParseJSONDateTime(const S: string; out Value: TDateTime): Boolean;

implementation

function TryParseJSONDateTime(const S: string; out Value: TDateTime): Boolean;
var
  FS: TFormatSettings;
begin
  Result := False;
  if S = '' then
    Exit;
    
  FS := TFormatSettings.Create;
  FS.DateSeparator := '-';
  FS.TimeSeparator := ':';
  FS.ShortDateFormat := 'yyyy-mm-dd';
  FS.ShortTimeFormat := 'hh:nn:ss';
  FS.LongTimeFormat := 'hh:nn:ss.zzz';
  
  if Pos('T', S) > 0 then
  begin
    if Pos('.', S) > 0 then
      Result := TryStrToDateTime(S, Value, FS)
    else
    begin
      FS.LongTimeFormat := 'hh:nn:ss';
      Result := TryStrToDateTime(S, Value, FS);
    end;
  end
  else
  begin
    Result := TryStrToDate(S, Value, FS);
  end;
end;

{ TSimpleJson }

constructor TSimpleJson.Create;
begin
  inherited Create;
  FObject := System.JSON.TJSONObject.Create;
  FOwned := True;
end;

constructor TSimpleJson.Create(AObject: System.JSON.TJSONObject; AOwned: Boolean);
begin
  inherited Create;
  FObject := AObject;
  FOwned := AOwned;
end;

destructor TSimpleJson.Destroy;
begin
  if FOwned and Assigned(FObject) then
    FObject.Free;
  inherited;
end;

class function TSimpleJson.Parse(const JSONString: string): IJson;
var
  Value: System.JSON.TJSONValue;
begin
  Value := System.JSON.TJSONObject.ParseJSONValue(JSONString);
  if Value is System.JSON.TJSONObject then
    Result := TSimpleJson.Create(System.JSON.TJSONObject(Value), True)
  else
  begin
    Value.Free;
    Result := nil;
  end;
end;

class function TSimpleJson.ParseFile(const FileName: string): IJson;
var
  List: TStringList;
begin
  List := TStringList.Create;
  try
    List.LoadFromFile(FileName, TEncoding.UTF8);
    Result := Parse(List.Text);
  finally
    List.Free;
  end;
end;

function TSimpleJson.GetS(const Key: string): string;
var
  Value: System.JSON.TJSONValue;
begin
  Result := '';
  if FObject.TryGetValue(Key, Value) then
    Result := Value.Value;
end;

procedure TSimpleJson.SetS(const Key, Value: string);
begin
  FObject.RemovePair(Key);
  FObject.AddPair(Key, Value);
end;

function TSimpleJson.GetI(const Key: string): Integer;
var
  Value: System.JSON.TJSONValue;
begin
  Result := 0;
  if FObject.TryGetValue(Key, Value) then
  begin
    if Value is System.JSON.TJSONNumber then
      Result := System.JSON.TJSONNumber(Value).AsInt
    else
      TryStrToInt(Value.Value, Result);
  end;
end;

procedure TSimpleJson.SetI(const Key: string; Value: Integer);
begin
  FObject.RemovePair(Key);
  FObject.AddPair(Key, Value);
end;

function TSimpleJson.GetF(const Key: string): Double;
var
  Value: System.JSON.TJSONValue;
begin
  Result := 0.0;
  if FObject.TryGetValue(Key, Value) then
  begin
    if Value is System.JSON.TJSONNumber then
      Result := System.JSON.TJSONNumber(Value).AsDouble
    else
      TryStrToFloat(Value.Value, Result);
  end;
end;

procedure TSimpleJson.SetF(const Key: string; Value: Double);
begin
  FObject.RemovePair(Key);
  FObject.AddPair(Key, Value);
end;

function TSimpleJson.GetB(const Key: string): Boolean;
var
  Value: System.JSON.TJSONValue;
begin
  Result := False;
  if FObject.TryGetValue(Key, Value) then
  begin
    if Value is System.JSON.TJSONBool then
      Result := System.JSON.TJSONBool(Value).AsBoolean
    else
      Result := SameText(Value.Value, 'true');
  end;
end;

procedure TSimpleJson.SetB(const Key: string; Value: Boolean);
begin
  FObject.RemovePair(Key);
  FObject.AddPair(Key, Value);
end;

function TSimpleJson.GetD(const Key: string): TDateTime;
var
  Value: System.JSON.TJSONValue;
  StrValue: string;
begin
  Result := 0;
  if FObject.TryGetValue(Key, Value) then
  begin
    StrValue := Value.Value;
    TryParseJSONDateTime(StrValue, Result);
  end;
end;

procedure TSimpleJson.SetD(const Key: string; Value: TDateTime);
begin
  FObject.RemovePair(Key);
  FObject.AddPair(Key, FormatDateTime(JSON_DATE_FORMAT, Value));
end;

function TSimpleJson.GetO(const Key: string): IJson;
var
  Value: System.JSON.TJSONValue;
  NewObj: System.JSON.TJSONObject;
begin
  Result := nil;
  if FObject.TryGetValue(Key, Value) then
  begin
    if Value is System.JSON.TJSONObject then
      Result := TSimpleJson.Create(System.JSON.TJSONObject(Value), False);
  end
  else
  begin
    NewObj := System.JSON.TJSONObject.Create;
    FObject.AddPair(Key, NewObj);
    Result := TSimpleJson.Create(NewObj, False);
  end;
end;

function TSimpleJson.GetA(const Key: string): IJsonArray;
var
  Value: System.JSON.TJSONValue;
  NewArr: System.JSON.TJSONArray;
begin
  Result := nil;
  if FObject.TryGetValue(Key, Value) then
  begin
    if Value is System.JSON.TJSONArray then
      Result := TSimpleJsonArray.Create(System.JSON.TJSONArray(Value), False);
  end
  else
  begin
    NewArr := System.JSON.TJSONArray.Create;
    FObject.AddPair(Key, NewArr);
    Result := TSimpleJsonArray.Create(NewArr, False);
  end;
end;

function TSimpleJson.GetPath(const Path: string): string;
var
  Parts: TArray<string>;
  CurrentValue: System.JSON.TJSONValue;
  CurrentObj: System.JSON.TJSONObject;
  CurrentArr: System.JSON.TJSONArray;
  i, Index: Integer;
  Key: string;
begin
  Result := '';
  Parts := Path.Split(['.', '[', ']'], TStringSplitOptions.ExcludeEmpty);
  CurrentValue := FObject;
  
  for i := 0 to Length(Parts) - 1 do
  begin
    Key := Parts[i];
    
    if CurrentValue is System.JSON.TJSONObject then
    begin
      CurrentObj := System.JSON.TJSONObject(CurrentValue);
      if not CurrentObj.TryGetValue(Key, CurrentValue) then
        Exit;
    end
    else if CurrentValue is System.JSON.TJSONArray then
    begin
      CurrentArr := System.JSON.TJSONArray(CurrentValue);
      if TryStrToInt(Key, Index) and (Index >= 0) and (Index < CurrentArr.Count) then
        CurrentValue := CurrentArr.Items[Index]
      else
        Exit;
    end
    else
      Exit;
  end;
  
  if Assigned(CurrentValue) then
    Result := CurrentValue.Value;
end;

function TSimpleJson.Contains(const Key: string): Boolean;
var
  Value: System.JSON.TJSONValue;
begin
  Result := FObject.TryGetValue(Key, Value);
end;

procedure TSimpleJson.Remove(const Key: string);
begin
  FObject.RemovePair(Key);
end;

procedure TSimpleJson.Clear;
begin
  FObject.Free;
  FObject := System.JSON.TJSONObject.Create;
end;

function TSimpleJson.GetKeys: TArray<string>;
var
  i: Integer;
begin
  SetLength(Result, FObject.Count);
  for i := 0 to FObject.Count - 1 do
    Result[i] := FObject.Pairs[i].JsonString.Value;
end;

function TSimpleJson.GetCount: Integer;
begin
  Result := FObject.Count;
end;

function TSimpleJson.ToJSON: string;
begin
  Result := FObject.ToJSON;
end;

function TSimpleJson.Format: string;
begin
  Result := FObject.Format;
end;

{ TSimpleJsonArray }

constructor TSimpleJsonArray.Create;
begin
  inherited Create;
  FArray := System.JSON.TJSONArray.Create;
  FOwned := True;
  FJsonWrappers := TObjectList<TSimpleJson>.Create(False);
  FArrayWrappers := TObjectList<TSimpleJsonArray>.Create(False);
end;

constructor TSimpleJsonArray.Create(AArray: System.JSON.TJSONArray; AOwned: Boolean);
begin
  inherited Create;
  FArray := AArray;
  FOwned := AOwned;
  FJsonWrappers := TObjectList<TSimpleJson>.Create(False);
  FArrayWrappers := TObjectList<TSimpleJsonArray>.Create(False);
end;

destructor TSimpleJsonArray.Destroy;
begin
  FJsonWrappers.Free;
  FArrayWrappers.Free;
  if FOwned and Assigned(FArray) then
    FArray.Free;
  inherited;
end;

class function TSimpleJsonArray.Parse(const JSONString: string): IJsonArray;
var
  Value: System.JSON.TJSONValue;
begin
  Value := System.JSON.TJSONObject.ParseJSONValue(JSONString);
  if Value is System.JSON.TJSONArray then
    Result := TSimpleJsonArray.Create(System.JSON.TJSONArray(Value), True)
  else
  begin
    Value.Free;
    Result := nil;
  end;
end;

function TSimpleJsonArray.GetCount: Integer;
begin
  Result := FArray.Count;
end;

function TSimpleJsonArray.GetItem(Index: Integer): IJson;
var
  Value: System.JSON.TJSONValue;
  Json: TSimpleJson;
begin
  Result := nil;
  if (Index >= 0) and (Index < FArray.Count) then
  begin
    Value := FArray.Items[Index];
    if Value is System.JSON.TJSONObject then
    begin
      Json := TSimpleJson.Create(System.JSON.TJSONObject(Value), False);
      FJsonWrappers.Add(Json);
      Result := Json;
    end;
  end;
end;

function TSimpleJsonArray.GetO(Index: Integer): IJson;
begin
  Result := GetItem(Index);
end;

function TSimpleJsonArray.GetS(Index: Integer): string;
begin
  Result := '';
  if (Index >= 0) and (Index < FArray.Count) then
    Result := FArray.Items[Index].Value;
end;

function TSimpleJsonArray.GetI(Index: Integer): Integer;
var
  Value: System.JSON.TJSONValue;
begin
  Result := 0;
  if (Index >= 0) and (Index < FArray.Count) then
  begin
    Value := FArray.Items[Index];
    if Value is System.JSON.TJSONNumber then
      Result := System.JSON.TJSONNumber(Value).AsInt;
  end;
end;

function TSimpleJsonArray.GetF(Index: Integer): Double;
var
  Value: System.JSON.TJSONValue;
begin
  Result := 0.0;
  if (Index >= 0) and (Index < FArray.Count) then
  begin
    Value := FArray.Items[Index];
    if Value is System.JSON.TJSONNumber then
      Result := System.JSON.TJSONNumber(Value).AsDouble;
  end;
end;

function TSimpleJsonArray.GetB(Index: Integer): Boolean;
var
  Value: System.JSON.TJSONValue;
begin
  Result := False;
  if (Index >= 0) and (Index < FArray.Count) then
  begin
    Value := FArray.Items[Index];
    if Value is System.JSON.TJSONBool then
      Result := System.JSON.TJSONBool(Value).AsBoolean;
  end;
end;

function TSimpleJsonArray.GetD(Index: Integer): TDateTime;
var
  Value: System.JSON.TJSONValue;
  StrValue: string;
begin
  Result := 0;
  if (Index >= 0) and (Index < FArray.Count) then
  begin
    Value := FArray.Items[Index];
    StrValue := Value.Value;
    TryParseJSONDateTime(StrValue, Result);
  end;
end;

function TSimpleJsonArray.Add(const Value: string): IJsonArray;
begin
  FArray.Add(Value);
  Result := Self;
end;

function TSimpleJsonArray.Add(Value: Integer): IJsonArray;
begin
  FArray.Add(Value);
  Result := Self;
end;

function TSimpleJsonArray.Add(Value: Double): IJsonArray;
begin
  FArray.Add(Value);
  Result := Self;
end;

function TSimpleJsonArray.Add(Value: Boolean): IJsonArray;
begin
  FArray.Add(Value);
  Result := Self;
end;

function TSimpleJsonArray.Add(Value: TDateTime): IJsonArray;
begin
  FArray.Add(FormatDateTime(JSON_DATE_FORMAT, Value));
  Result := Self;
end;

function TSimpleJsonArray.AddObject: IJson;
var
  NewObj: System.JSON.TJSONObject;
  Json: TSimpleJson;
begin
  NewObj := System.JSON.TJSONObject.Create;
  FArray.Add(NewObj);
  Json := TSimpleJson.Create(NewObj, False);
  FJsonWrappers.Add(Json);
  Result := Json;
end;

function TSimpleJsonArray.AddArray: IJsonArray;
var
  NewArr: System.JSON.TJSONArray;
  Arr: TSimpleJsonArray;
begin
  NewArr := System.JSON.TJSONArray.Create;
  FArray.Add(NewArr);
  Arr := TSimpleJsonArray.Create(NewArr, False);
  FArrayWrappers.Add(Arr);
  Result := Arr;
end;

procedure TSimpleJsonArray.Delete(Index: Integer);
begin
  if (Index >= 0) and (Index < FArray.Count) then
    FArray.Remove(Index);
end;

procedure TSimpleJsonArray.Clear;
begin
  FArray.Free;
  FArray := System.JSON.TJSONArray.Create;
  FJsonWrappers.Clear;
  FArrayWrappers.Clear;
end;

function TSimpleJsonArray.ToJSON: string;
begin
  Result := FArray.ToJSON;
end;

function TSimpleJsonArray.Format: string;
begin
  Result := FArray.Format;
end;

end.
