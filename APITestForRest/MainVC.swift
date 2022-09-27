//
//  MainVC.swift
//  APITestForRest
//
//  Created by yeoh on 18/09/2022.
//

import UIKit
import Kanna
import CoreData

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
    var tableViewCellPrimaryKey: String = ""
    var cellIndexPath: Int = 0 //取得某行列的cell
    var preIndexPath: Int = 0 //刪除行列前的資料數量
    var fetchResultController: NSFetchedResultsController<MaskInfoTable>!
    let context = CoreDataManager.shared.context
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        setupFetchResultController()
        fetchMaskInfo()
        delegate()
        parseHTML()
        print(fetchResultController.fetchedObjects?.count)
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
    
    func setupFetchResultController() {
        fetchResultController = CoreDataManager.shared.createMaskInfoTableFetchResultController(sorter: "town")
        fetchResultController.delegate = self
        do {
            try fetchResultController.performFetch()
        }
        catch {
            print("error: \(error)")
        }
    }
    func delete(item: MaskInfoTable){
        context.delete(item)
        do {
            try context.save()
        }
        catch {
            print("error: \(error)")
        }
    }
    // 處理拿到的API資料 篩出台中市的以後放入maskInfo:[MaskInfo]並存入realm資料庫中
    func fetchMaskInfo(){
        NetworkManager.shared.getPharmaciesData { (response: Pharmacies?) in
            DispatchQueue.main.async {
                self.view.isUserInteractionEnabled = false
                self.view.addSubview(self.indicatorView)
                self.apiActivityIndicator.startAnimating()
            }
            guard let featureCount = response?.features.count else { return }
            //如果資料庫有資料
            if self.fetchResultController.fetchedObjects?.count ?? 0 > 0 {
                for i in 0 ..< featureCount {
                    guard let id = response?.features[i].properties.id else { return }
                    guard let name = response?.features[i].properties.name else { return }
                    guard let phone = response?.features[i].properties.phone else { return }
                    guard let address = response?.features[i].properties.address else { return }
                    guard let mask_adult = response?.features[i].properties.mask_adult else { return }
                    guard let mask_child = response?.features[i].properties.mask_child else { return }
                    guard let county = response?.features[i].properties.county else { return }
                    guard let town = response?.features[i].properties.town else { return }
                    guard let cunli = response?.features[i].properties.cunli else { return }
                    
                    
                    
                    if county == "臺中市"{
                        self.maskInfo.append(MaskInfo(id: id,
                                                      name: name,
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
                    guard let id = response?.features[i].properties.id else { return }
                    guard let name = response?.features[i].properties.name else { return }
                    guard let phone = response?.features[i].properties.phone else { return }
                    guard let address = response?.features[i].properties.address else { return }
                    guard let mask_adult = response?.features[i].properties.mask_adult else { return }
                    guard let mask_child = response?.features[i].properties.mask_child else { return }
                    guard let county = response?.features[i].properties.county else { return }
                    guard let town = response?.features[i].properties.town else { return }
                    guard let cunli = response?.features[i].properties.cunli else { return }
                    
                    
                    
                    if county == "臺中市"{
                        self.maskInfo.append(MaskInfo(id: id,
                                                      name: name,
                                                      phone: phone,
                                                      address: address,
                                                      mask_adult: mask_adult,
                                                      mask_child: mask_child,
                                                      county: county,
                                                      town: town,
                                                      cunli: cunli))
                        
                        let maskInfo = MaskInfo(id: id,
                                                name: name,
                                                phone: phone,
                                                address: address,
                                                mask_adult: mask_adult,
                                                mask_child: mask_child,
                                                county: county,
                                                town: town,
                                                cunli: cunli)
                        
                        //新增資料到資料庫
                        CoreDataManager.shared.addData(maskInfo: maskInfo)
                        
                    }
                }
            }
            
            self.getTownName()
            DispatchQueue.main.async {
                self.apiActivityIndicator.stopAnimating()
                self.indicatorView.removeFromSuperview()
                self.view.isUserInteractionEnabled = true
                
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
    //取得maskAPI提供的id作為primaryKey
    func getCellPrimaryKey() {
        let frc = fetchResultController.fetchedObjects?[self.cellIndexPath]
            print("cellIndexPath in Getcell primary key: \(cellIndexPath)")
            if !fetchResultController.fetchedObjects!.isEmpty {
                tableViewCellPrimaryKey = (frc?.id)!
            }
            print(tableViewCellPrimaryKey)
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
        //修改fetchResultController篩選條件
        fetchResultController.fetchRequest.predicate = NSPredicate(format: "town == %@", selectedTown)
        do {
            try fetchResultController.performFetch()
        }
        catch {
            print("error: \(error)")
        }
        DispatchQueue.main.async {
            self.townBtn.setTitle(self.selectedTown, for: .normal)
            self.listTableView.reloadData()
            self.removePickView()
        }
    }

}

extension MainVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let maskInfoData = fetchResultController.sections![section]
        preIndexPath = maskInfoData.numberOfObjects
            return maskInfoData.numberOfObjects
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CustomTVC.cellIdentifier, for: indexPath) as! CustomTVC
        let maskInfoData = fetchResultController.object(at: indexPath)
        
        cell.nameLabel.text = "藥局: " + (maskInfoData.name ?? "")
        cell.townLabel.text = "地區: " + (maskInfoData.town ?? "")
        cell.adultMaskLabel.text = "成人口罩: " + String(maskInfoData.mask_adult)
        cell.childMaskLabel.text = "兒童口罩: " + String(maskInfoData.mask_child)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let maskInfoData = fetchResultController.object(at: indexPath)
        listTableView.deselectRow(at: indexPath, animated: true)
        let alert = UIAlertController(title: "請問是否刪除該筆資料",
                                      message: "",
                                      preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "刪除", style: .destructive, handler: { _ in
            let maskInfoData = self.fetchResultController.object(at: indexPath)
            print(self.fetchResultController.fetchRequest.predicate)
                            self.cellIndexPath = indexPath.row
                            self.getCellPrimaryKey()
            print("cell indexpath in editingStyle : %@",self.cellIndexPath)
        print(maskInfoData)
        print("get mask info data cell id : \(maskInfoData.id)")
            print("get tableview Cell PrimaryKey : \(self.tableViewCellPrimaryKey)")
            if maskInfoData.id == self.tableViewCellPrimaryKey {
            CoreDataManager.shared.deleteData(maskInfoTable: maskInfoData)
        }
            print("上次表格的行數： \(self.preIndexPath)  當前表格行數： \(self.fetchResultController.fetchedObjects?.count)")
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { _ in
            return
        }))
        self.present(alert, animated: true, completion: nil)
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

extension MainVC: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        listTableView.beginUpdates()
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .move:
            listTableView.deleteRows(at: [indexPath!], with: .fade)
            listTableView.insertRows(at: [newIndexPath!], with: .fade)
        case .insert:
            print("這是新的indexpath : \(newIndexPath)")
            listTableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            print("這是舊的indexpath : \(indexPath)")
            listTableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            listTableView.reloadRows(at: [indexPath!], with: .fade)
        default:
            listTableView.reloadData()
        }
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        listTableView.endUpdates()
    }
}
