import Buffer "mo:base/Buffer";
import D "mo:base/Debug";
import Principal "mo:base/Principal";

import C "mo:candid_stringify/candid_stringify";

import Canistergeek "./canistergeek";
import LoggerTypes "./logger/typesModule"

actor {

    stable var _canistergeekMonitorUD: ? Canistergeek.UpgradeData = null;
    private let canistergeekMonitor = Canistergeek.Monitor();
    
    stable var _canistergeekLoggerUD: ? Canistergeek.LoggerUpgradeData = null;
    private let canistergeekLogger = Canistergeek.Logger();

    type RecordExample = {
        name: Text;
        age : Int;
    };

    type ComplexExample = {
        name : Text;
        age : Int;
        owner : Principal;
        address : {
            street : Text;
            phone : ?Text;
            location : {
                state : Text; 
            };
        };
        language : {
        #english : Text;
        #spanish : Text;
        #french : Text;
        };
        music : [MusicTypes];
        // candy : Candy.CandyValue;
    };

    type MusicTypes = {
        rock : Bool;
        dance : Text;
    };

    public shared({caller}) func simple_string (s : Text) : async Text {
        var blob = to_candid(s);
        canistergeekLogger.logMessage("simple_string", blob, ?caller);
        s;
    };
    public shared({caller}) func simple_record (s : RecordExample) : async RecordExample {
        var blob = to_candid(s);
        canistergeekLogger.logMessage("simple_record", blob, ?caller);
        s;
    };

    public shared({caller}) func complex_example (s : ComplexExample) : async ComplexExample {
        var blob = to_candid(s);
        canistergeekLogger.logMessage("complex_example", blob, ?caller);
        s;
    };
    
    public query ({caller}) func getCanisterLog(request: ?Canistergeek.CanisterLogRequest) : async ?Canistergeek.CanisterLogResponseString {
        
       var x = canistergeekLogger.getLog(request);

       var mBuffer = Buffer.Buffer<LoggerTypes.LogMessagesDataString>(0);
       var lastAnalyzedMessageTimeNanos : ?Nat64 = ?0;
        switch(x){
            case(?m) {
                switch(m) {
                    case(#messages(v)) {
                        lastAnalyzedMessageTimeNanos := v.lastAnalyzedMessageTimeNanos;

                        for(i in v.data.vals()){
                            // Get the blobs and convert to string  - we need to pass an array we object candid keys
                            var strData = C.stringify(i.data, ["name", "age", "owner", "address", "street", "phone", "location", "state", "language","spanish", "english", "french", "music", "rock", "dance" ]);
                           
                            var item = {caller = i.caller; data = strData; message = i.message; timeNanos = i.timeNanos};
                            mBuffer.add(item); 
                        }
                        
                    };
                    case(#messagesInfo(v)) {                      
                        return ?(#messagesInfo{
                                    features = v.features;
                                    lastTimeNanos = v.lastTimeNanos;
                                    count = v.count;
                                    firstTimeNanos = v.firstTimeNanos;
                                })
                    };
                };
            };
            case(_) D.print("This is null");
        };
       
       var arr = Buffer.toArray(mBuffer);
       ?(#messages(
                { 
                    data = arr; 
                    lastAnalyzedMessageTimeNanos = lastAnalyzedMessageTimeNanos
                }
            )
        );
    };

     public query ({caller}) func getCanisterMetrics(parameters: Canistergeek.GetMetricsParameters): async ?Canistergeek.CanisterMetrics {
        
        canistergeekMonitor.getMetrics(parameters);
    };

    public shared ({caller}) func collectCanisterMetrics(): async () {
        
        canistergeekMonitor.collectMetrics();
    };

    system func preupgrade() {
        _canistergeekMonitorUD := ? canistergeekMonitor.preupgrade();
        _canistergeekLoggerUD := ? canistergeekLogger.preupgrade();
    };

    system func postupgrade() { 
        canistergeekMonitor.postupgrade(_canistergeekMonitorUD);
        _canistergeekMonitorUD := null;
        
        canistergeekLogger.postupgrade(_canistergeekLoggerUD);
        _canistergeekLoggerUD := null;
        canistergeekLogger.setMaxMessagesCount(3000);
        
        // canistergeekLogger.logMessage("postupgrade");
    };

}