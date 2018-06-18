//
//  OSVerboseBoot.swift
//  The-Macintosh-in-1984
//
//  Created by Xue Yu on 5/26/18.
//  Copyright © 2018 XueYu. All rights reserved.
//

import UIKit


/// scroll text view
class AZVerboseBoot: UIView {
    
    private var textView: UITextView
    private var timer: Timer?
    private var counter : Int
    private let messages = [
        "MAC Framework successfully initialized",
        "This is just a boot squence and nothing here actually makes sense.",
        "Created By Antonio Zaitoun https://github.com/minitour",
        "using 10485 buffer headers and 7290 cluster IO buffer headers",
        "FakeSMCKeyStore: started directHW: Driver v1.3 (compiLed on Jun 8 1985) loaded. Visit http coresystems.de or more information.",
        "AppleKeyStore starting (BUILT: Sep 19 1985 22:20:34)",
        "FakeSMC v6.0.1018 Copiright 1985 netkas. slice. usr-sse2. kozLek. na G. RehabMan. HLL rights reserved.",
        "IOHPIC: Version Ox11 Vectors 64:87 akeSMC: 10 preconfigured keys added",
        "ACPI: System State ISO S57 (SO) mci (buiLd 22:16:29 Sep 19 1985).",
        "Flags Ox61008. pfm64 (36 cpu) 0x017111997 0x80000000 I",
        "PCI configuration begin 7 onsoLe reLocated to Oxe0000000 I PCI configuration end. bridges 3.",
        "devices 8 7 .TC: OnLy singLe RHM bank (128 bytes) SBF: 0.205 We couLd not find a corresponding USB EHCI controLLer for our OHCI controLLer at PCI de umber31.",
        "MC: successfuLLy initiaLized mcache: 1 CPU(s).",
        "64 bytes CPU cache Line size nbinit: done [64 MB totaL pooL size. (42/21)",
        "spLit7 'thread support HBORTS when sync kerneL primitives misused -ooting via boot-uuid from chosen: 9073466E-1860-34E7-8H84-30894065C3F4 aiting on",
        "key,I0ProviderCLass</keyXstring ID = 1,IOResources g, key,",
        "IOResourceMatc r g IO = 2,boot-uuLd-media g duc om.appLe.HppLeFSCompressionTypeRib kmod ",
        "start om.appLe.HppLeFSCompressionTypeDataLess kmod start om.appLe.HppLeFSCompressionTypeZLib Load succeeded om.appLe.HppLeFSCompressionTypeDataLess ",
        "Load succeeded SBF: 0.256 HppLeUSBOHCI::CheckSLeepCapabiLity - controLLer wiLL be unLoaded across sLeep SBF: 0.260 HppLeUSBOHCI::CheckSLeepCapabiLity - controLLer wiLL be",
        "unLoaded across sLeep ot boot device = IOService:/HppLeHCPIPLatformExpert/PCIONle0000/HppLeHCPIPCl/pci8086.2829.F.2/HppLeICHBHHCl/PRTON/I0HHCIDe ce@O/HppLeHHCID IOHHCI:",
        "Loading net.crofis.ui package UUID = 0x17111997",
        ".ckStorageDevice/IOBLockStorageDriver/VBOX HHRODISK Media/IOGUIDPartitio ;SD root: disk0s2. hmjor 1. minor 2 •nL: 6(1. 2): ",
        "repLay_journaL: from: 935936 to: 2162688 (joffset Oxa0000) nL: 6(1. 2): ",
        "journaL repLay done. Ifs: hmmted Stuff on device root_device om.appLe.Launchd com.appLe.Launchd LaunchdI17 has started up.",
        "om:ppLe.Launchd 1 com.appLe.Launchd Verbose boot.",
        "will Log to /dev/consoL. om.appLe.Launchd 1 com.appLe.Launchd Shutdown Logging is enabled. /dev/rdisk0s2 (NO WRITE)"
    ]
    

    override init(frame: CGRect) {
        textView = UITextView()
        textView.backgroundColor = .black
        textView.textColor = .white
        textView.isEditable = false
        textView.isSelectable = false
        textView.isUserInteractionEnabled = false
        textView.font = SystemSettings.normalSizeFont
        counter = 0
        
        super.init(frame: frame)
        self.addSubview(textView)
        layer.cornerRadius = 5
        layer.masksToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textView.frame = bounds
    }
    
    
    
    /// load Boot - the scroll text view
    ///
    /// - Parameters:
    ///   - duration: time
    ///   - completion: once finished, the closure we do
    func loadBootWithDuration(_ duration: TimeInterval,completion: (()->Void)?) {
        
        let intervalPerItem = duration / Double(messages.count)
        
        timer = Timer.scheduledTimer(withTimeInterval: intervalPerItem, repeats: true) { _ in
            
            if self.counter == self.messages.count{
                self.timer?.invalidate()
                completion?()
                return
            }
            
            self.textView.text = self.textView.text + (self.counter == 0 ? "" : "\n") + self.messages[self.counter]
            let stringLength = self.textView.text.count
            self.textView.scrollRangeToVisible(NSMakeRange(stringLength - 1, 0))
            self.counter += 1
        }
    }
    
}
