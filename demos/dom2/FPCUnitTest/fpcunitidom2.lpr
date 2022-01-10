program fpcunitidom2;

{$mode objfpc}{$H+}

uses
  Interfaces, Forms, GuiTestRunner, XPTest_idom2_TestDOM2Methods, domTestCase;

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TGuiTestRunner, TestRunner);
  Application.Run;
end.

