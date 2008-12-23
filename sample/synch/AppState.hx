typedef TAConnecting = { var pendingConnects:Int; var connects:Int; var beginTime:Float; }

enum AppState{
    AInit;
    AConnecting(?_:TAConnecting);
    ASynchronize;
    AUpdating;
    AError;
    ADone;
}
