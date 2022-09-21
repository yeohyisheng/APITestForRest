//
//  MainVC.swift
//  APITestForRest
//
//  Created by yeoh on 18/09/2022.
//

import UIKit
import RealmSwift
import Kanna

class MainVC: UIViewController {
    
    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var townPickerView: UIPickerView!
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var apiActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var townBtn: UIButton!
    @IBOutlet weak var sentenceLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var spacing: NSLayoutConstraint!
    
    
    var toolBar = UIToolbar()
    var submitBtn = UIButton()
    var cancelBtn = UIButton()
    var maskInfo: [MaskInfo] = [] //Pickerview篩選地區前暫存的array
    var townList: [Pharmacies.Feature.Properties] = [] //pickerview使用的資料
    var maskInfoDBNameArray: [String] = []
    var maskInfoDBTownArray: [String] = []
    var maskInfoDBAdultMaskNumberArray: [String] = []
    var maskInfoDBChildMaskNumberArray: [String] = []
    var townListForPickerView: [String] = []
    var cacheTown: String = ""
    var selectedTown: String = "豐原區"
    var tableViewCellPrimaryKey:ObjectId = ObjectId.generate()
    var cellIndexPath: Int = 0 //取得某行列的cell
    var preIndexPath: Int = 0 //刪除行列前的資料數量
    var isSelectTownMode: Bool = false //是否為pickerview選擇模式
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        fetchMaskInfo()
        delegate()
        parseHTML()
    }
    
    //點擊townBtn彈出pickerview及toolbar生成
    @IBAction func selectTown(_ sender: Any) {
        toolBar.removeFromSuperview()
        UIView.animate(withDuration: 0.5) {
            self.spacing.constant = -216
            self.displayToolBar()
        }
        print("Im tapping")
    }
    
    //delegate datasource
    func delegate(){
        listTableView.delegate = self
        listTableView.dataSource = self
        townPickerView.delegate = self
        townPickerView.dataSource = self
        listTableView.register(UINib(nibName: "CustomTVC", bundle: nil), forCellReuseIdentifier: CustomTVC.cellIdentifier)
    }
    
    // 處理拿到的API資料 篩出台中市的以後放入maskInfo:[MaskInfo]並存入realm資料庫中
    func fetchMaskInfo(){
        NetworkManager.shared.getPharmaciesData { (response: Pharmacies?) in
            guard let featureCount = response?.features.count else { return }
            let realm = try! Realm()
            let result = realm.objects(MaskInfoDB.self)
            //如果資料庫有資料
            if result.count > 0 {
                for i in 0 ..< featureCount {
                    guard let name = response?.features[i].properties.name else { return }
                    guard let phone = response?.features[i].properties.phone else { return }
                    guard let address = response?.features[i].properties.address else { return }
                    guard let mask_adult = response?.features[i].properties.mask_adult else { return }
                    guard let mask_child = response?.features[i].properties.mask_child else { return }
                    guard let county = response?.features[i].properties.county else { return }
                    guard let town = response?.features[i].properties.town else { return }
                    guard let cunli = response?.features[i].properties.cunli else { return }
                    
                    
                    
                    if county == "臺中市"{
                        self.maskInfo.append(MaskInfo(name: name,
                                                      phone: phone,
                                                      address: address,
                                                      mask_adult: mask_adult,
                                                      mask_child: mask_child,
                                                      county: county,
                                                      town: town,
                                                      cunli: cunli))
                    }
                }
            }//如果資料庫第一次載入
            else {
                for i in 0 ..< featureCount {
                    guard let name = response?.features[i].properties.name else { return }
                    guard let phone = response?.features[i].properties.phone else { return }
                    guard let address = response?.features[i].properties.address else { return }
                    guard let mask_adult = response?.features[i].properties.mask_adult else { return }
                    guard let mask_child = response?.features[i].properties.mask_child else { return }
                    guard let county = response?.features[i].properties.county else { return }
                    guard let town = response?.features[i].properties.town else { return }
                    guard let cunli = response?.features[i].properties.cunli else { return }
                    
                    
                    
                    if county == "臺中市"{
                        self.maskInfo.append(MaskInfo(name: name,
                                                      phone: phone,
                                                      address: address,
                                                      mask_adult: mask_adult,
                                                      mask_child: mask_child,
                                                      county: county,
                                                      town: town,
                                                      cunli: cunli))
                        
                        let maskInfo = MaskInfo(name: name,
                                                phone: phone,
                                                address: address,
                                                mask_adult: mask_adult,
                                                mask_child: mask_child,
                                                county: county,
                                                town: town,
                                                cunli: cunli)
                        
                        //新增資料到資料庫
                        LocalDatabase.shared.add(maskInfo: maskInfo)
                        
                        
                    }
                }
            }
            
            self.getTownName()
            DispatchQueue.main.async {
                self.listTableView.reloadData()
            }
        } failure: { errorMessage in
            print(errorMessage)
        }
        
    }
    
    //對解碼後爬到的html資訊做字串分割 然後在畫面做顯示處理
    func parseHTML() {
        NetworkManager.shared.loadData { response in
            if let doc = try? HTML(html: response ?? "", encoding: .utf8){
                let oneDaySentence = doc.xpath("/html/body/div[@class='wrapper']/article/div/div/div[@class='rwdfix']").first!.text
                let str1 = oneDaySentence?.replacingOccurrences(of: "\n", with: "")
                let str2 = str1?.replacingOccurrences(of: "\t", with: "")
                var str3 = str2?.trimmingCharacters(in: .whitespacesAndNewlines)
                let startIndex = str3?.startIndex
                let endIndex = str3?.endIndex
                let subIndex:String.Index = str3!.index(startIndex!, offsetBy: 97)
                let resultStringForAuthor = str3?.substring(from: subIndex)
                let stringRemoveAuthor = str3?.removeSubrange(subIndex..<endIndex!)
                let resultStringForOneDaySentence = str3?.trimmingCharacters(in: .whitespacesAndNewlines)
                print("oneDaySentence: \(oneDaySentence)")
                print("str1: \(str1)")
                print("str2: \(str2)")
                print("str3: \(str3)")
                print("resultString: \(resultStringForAuthor)")
                print("Another result String: \(resultStringForOneDaySentence)")
                DispatchQueue.main.async {
                    self.sentenceLabel.text = resultStringForOneDaySentence
                    self.authorLabel.text = resultStringForAuthor
                    self.sentenceLabel.sizeToFit()
                    self.authorLabel.sizeToFit()
                }
            }
        } failure: { errorMessage in
            print(errorMessage)
        }
    }
    //取得pickerView所需要使用的區域資訊
    func getTownName() {
        var nextTown: String = ""
        for i in maskInfo{
            nextTown = i.town
            if nextTown != cacheTown{
                if !townListForPickerView.contains(nextTown) {
                    self.cacheTown = nextTown
                    self.townListForPickerView.append(self.cacheTown)
                }
            }
        }
        print(self.townListForPickerView)
        DispatchQueue.main.async {
            self.townPickerView.reloadAllComponents()
        }
    }
    //取得navigation的高度
    func getNavigationBarHight() -> CGFloat{
        if let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
            return navigationController.navigationBar.frame.size.height
        }else{
            return 0.0
        }
    }
    //取得realm定義的objectID作為primaryKey
    func getCellPrimaryKey() {
        let realm = try! Realm()
        let id = realm.objects(MaskInfoDB.self)
        //如不是選擇pickerview狀態下
        if isSelectTownMode == false{
            if id.count > 0 {
                tableViewCellPrimaryKey = id[self.cellIndexPath]._id
            }
            print(tableViewCellPrimaryKey)
        } else {
            let results = realm.objects(MaskInfoDB.self).filter("town == %@", selectedTown)
            if results.count > 0 {
                tableViewCellPrimaryKey = results[self.cellIndexPath]._id
            }
            print(tableViewCellPrimaryKey)
        }
    }
    //設置navigationBar
    func setNavigationBar(){
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.9953911901, green: 0.9881951213, blue: 1, alpha: 1)
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor : #colorLiteral(red: 0.9953911901, green: 0.9881951213, blue: 1, alpha: 1)]
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = self.navigationController?.navigationBar.standardAppearance
        self.title = "臺中市"
    }
    //生成toolbar
    func displayToolBar() {
        toolBar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 216 - getNavigationBarHight(), width: UIScreen.main.bounds.size.width, height: 50))
        toolBar.barStyle = .default
        toolBar.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        cancelBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
        cancelBtn.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        cancelBtn.setTitleColor(UIColor.black, for: .normal)
        cancelBtn.addTarget(self, action: #selector(removePickView), for: .touchUpInside)
        cancelBtn.titleLabel?.adjustsFontSizeToFitWidth = true;
        self.toolBar.addSubview(cancelBtn)
        submitBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
        submitBtn.setTitle(NSLocalizedString("Complete", comment: ""), for: .normal)
        submitBtn.setTitleColor(UIColor.black, for: .normal)
        submitBtn.addTarget(self, action: #selector(selectTownArea), for: .touchUpInside)
        submitBtn.titleLabel?.adjustsFontSizeToFitWidth = true;
        self.toolBar.addSubview(submitBtn)
        submitBtn.translatesAutoresizingMaskIntoConstraints = false
        cancelBtn.translatesAutoresizingMaskIntoConstraints = false
        let constraints1 = [cancelBtn.topAnchor.constraint(equalTo: self.toolBar.topAnchor, constant: 0),
                           cancelBtn.widthAnchor.constraint(equalToConstant: 50),
                           cancelBtn.leftAnchor.constraint(equalTo: self.toolBar.leftAnchor, constant: UIScreen.main.bounds.size.width/30),
                           cancelBtn.bottomAnchor.constraint(equalTo: self.toolBar.bottomAnchor, constant: 0)]
        NSLayoutConstraint.activate(constraints1)
        let constraints3 = [submitBtn.topAnchor.constraint(equalTo: self.toolBar.topAnchor, constant: 0),
                           submitBtn.widthAnchor.constraint(equalToConstant: 50),
                           submitBtn.trailingAnchor.constraint(equalTo: self.toolBar.trailingAnchor, constant: -UIScreen.main.bounds.size.width/30),
                           submitBtn.bottomAnchor.constraint(equalTo: self.toolBar.bottomAnchor, constant: 0)]
        NSLayoutConstraint.activate(constraints3)
        let titleLab = UILabel()
        titleLab.text = NSLocalizedString("Select Town", comment: "")
        self.toolBar.addSubview(titleLab)
        titleLab.translatesAutoresizingMaskIntoConstraints = false
        let constraints2 = [titleLab.centerXAnchor.constraint(equalTo: self.toolBar.centerXAnchor, constant: 0),
                            titleLab.centerYAnchor.constraint(equalTo: self.toolBar.centerYAnchor, constant: 0)]
        NSLayoutConstraint.activate(constraints2)
        self.view.addSubview(toolBar)
    }
    
    //移除pickerview及toolbar
    @objc func removePickView() {
        toolBar.removeFromSuperview()
        spacing.constant = 0
    }
    
    //當toolbar按下complete 將篩選成指定區域的資料並更新tableview顯示
    @objc func selectTownArea() {
        maskInfoDBNameArray = []
        maskInfoDBTownArray = []
        maskInfoDBAdultMaskNumberArray = []
        maskInfoDBChildMaskNumberArray = []
        isSelectTownMode = true
        let realm = try! Realm()
        let results = realm.objects(MaskInfoDB.self).filter("town == %@", selectedTown)
        if results.count > 0{
            for element in results {
                maskInfoDBNameArray.append("\(element.name)")
                maskInfoDBTownArray.append("\(element.town)")
                maskInfoDBAdultMaskNumberArray.append("\(element.mask_adult)")
                maskInfoDBChildMaskNumberArray.append("\(element.mask_child)")
            }
            listTableView.reloadData()
            removePickView()
        }
        
    }

}

extension MainVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let realm = try! Realm()
        let result = realm.objects(MaskInfoDB.self)
        if result.count > 0 {
            if !isSelectTownMode{
                preIndexPath = result.count
                return result.count
            }
            else {
               let results = realm.objects(MaskInfoDB.self).filter("town == %@", selectedTown)
               return results.count
           }
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CustomTVC.cellIdentifier, for: indexPath) as! CustomTVC
        let realm = try! Realm()
        let result = realm.objects(MaskInfoDB.self)
        
        if result.count > 0 {
            if !isSelectTownMode{
                for element in result {
                    maskInfoDBNameArray.append("\(element.name)")
                    maskInfoDBTownArray.append("\(element.town)")
                    maskInfoDBAdultMaskNumberArray.append("\(element.mask_adult)")
                    maskInfoDBChildMaskNumberArray.append("\(element.mask_child)")
                }
                cell.nameLabel.text = "藥局: " + maskInfoDBNameArray[indexPath.row]
                cell.townLabel.text = "地區: " + maskInfoDBTownArray[indexPath.row]
                cell.adultMaskLabel.text = "成人口罩: " + maskInfoDBAdultMaskNumberArray[indexPath.row]
                cell.childMaskLabel.text = "小孩口罩: " + maskInfoDBChildMaskNumberArray[indexPath.row]
                return cell
            } else {
                cell.nameLabel.text = "藥局: " + maskInfoDBNameArray[indexPath.row]
                cell.townLabel.text = "地區: " + maskInfoDBTownArray[indexPath.row]
                cell.adultMaskLabel.text = "成人口罩: " + maskInfoDBAdultMaskNumberArray[indexPath.row]
                cell.childMaskLabel.text = "小孩口罩: " + maskInfoDBChildMaskNumberArray[indexPath.row]
                return cell
            }
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {

            DispatchQueue.main.async {
                let realm = try! Realm()
                let result = realm.objects(MaskInfoDB.self)

                    self.cellIndexPath = indexPath.row
                    self.getCellPrimaryKey()
                    let deleteCell = realm.objects(MaskInfoDB.self).filter("_id == %@", self.tableViewCellPrimaryKey).first
                    try! realm.write{
                        realm.delete(deleteCell!)
                    }
                    print("上次表格的行數： \(self.preIndexPath)  當前表格行數： \(result.count)")
                //當資料被刪除時
                if (self.preIndexPath - result.count == 1){
                    print(indexPath)
                    tableView.beginUpdates()
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    tableView.endUpdates()
                }
                else if (self.preIndexPath - result.count == 0){
                    print("列表已更新")
                }
                else {
                    tableView.reloadData()
                }
                
            }
        }
    }
    


}

extension MainVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return townListForPickerView.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {

        return townListForPickerView[row]

    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if townListForPickerView.count > 0 {
            selectedTown = townListForPickerView[row]
            print (selectedTown)
        }
    }
}
