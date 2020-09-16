![](https://github.com/rainedAllNight/IndexBar/blob/master/IndexBar%401x.png)
# IndexBar
### A index bar for tableview with Swift

### 一个tableView的索引控件，UI仿照于微信联系人页面, 使用Swift编写


## Preview

![](https://github.com/rainedAllNight/IndexBar/blob/master/%E5%9B%BE%E5%83%8F.gif)

## Installation 

### Cocoapods

````
pod 'IndexBar'

````

### Platform & Swift version

* **>= iOS 10.0**
* **>= Swift 5.0**

## Usage 

### you can init the IndexBar with frame or start with storyBoard&xib(代码初始化或者直接在storyboard中使用)

````
        let indexBar = IndexBar(frame: CGRect(x: view.bounds.width - 24, y: 0, width: 40, height: view.bounds.height))
        indexBar.configure = { configure in
            configure.sectionWH = 16
            configure.titleFont = UIFont.systemFont(ofSize: 12)
            configure.backgroundColorForSelected = UIColor.color(withHex: "#53ED7C")
        }
        indexBar.setData(sectionTitles, tableView: tableView)
        view.addSubview(indexBar)

````

### IndexBar configure(相关配置项)

```
    /// section normal titcle color
    public var titleColor: UIColor = .lightGray
    /// section title font
    public var titleFont: UIFont = UIFont.systemFont(ofSize: 10)
    /// section selected titcle color
    public var titleColorForSelected: UIColor = .white
    /// section selected background color
    public var backgroundColorForSelected: UIColor = .blue
    /// section width&height
    public var sectionWH: CGFloat = 16
    /// section vertical spacing
    public var sectionSpacing: CGFloat = 4
    /// show bubble view, default is true
    public var showBubble = true
    /// the configure of the bubble view
    public var bubbleConfigure = BubbleConfigure()


```








