typedef TAConnecting = { var pendingConnects:Int; var connects:Int; var beginTime:Float; }

enum AppState{
    AInit;
    AConnecting(?_:TAConnecting);
    ABeginSynch;
    ASynchronizing;
    AUpdating;
    AError;
    ADone;
}
