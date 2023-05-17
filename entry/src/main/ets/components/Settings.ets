import { getTheme } from '../utils/Themes';
import { RadioDialog } from './dialog/RadioDialog';
import DataStore from '../utils/DataStore';
import Logger from '../utils/Logger';

export interface Preference<T> {

  key: string,
  type: 'switch' | 'radio'
  defaultValue: T
  values?: string[]
  onValueChange?: (key, value) => void

}

interface NormalPreference {
  info: string,
  onClick?: (event?: ClickEvent) => void
}

export interface SettingItem {
  title: string
  info?: string | Resource
  icon?: string | PixelMap | Resource
  iconBlendColor?: ResourceColor
  onClick?: (item: SettingItem, callback: () => void, event?: ClickEvent) => void
  preference?: Preference<any>
}

export interface SettingGroup {
  title?: string
  settings: SettingItem[]
}

@Preview
@Component
struct SettingRow {
  @StorageLink('theme') theme: number = 0
  @State info: string = ''
  private setting: SettingItem = null
  private infoRes: ResourceStr

  aboutToAppear() {
    this.infoRes = this.setting.info
    if (typeof this.setting.info === 'string') {
      this.info = this.setting.info
    }
  }

  build() {
    Row() {
      if (this.setting.icon) {
        Image(this.setting.icon)
          .width(24)
          .height(24)
          .margin({ right: 16 })
          .fillColor(this.setting.iconBlendColor)
          .objectFit(ImageFit.Contain)
      }

      Column() {
        Text(this.setting.title)
          .fontSize(15)
          .fontWeight(450)
          .fontColor(getTheme(this.theme).color_text_major)
          .align(Alignment.Start)
          .width('100%')
        if (this.info) {
          Text(this.info)
            .fontSize(12)
            .fontWeight(350)
            .margin({ top: 4 })
            .fontColor(getTheme(this.theme).color_text_minor)
            .align(Alignment.Start)
            .width('100%')
        } else if (this.infoRes) {
          Text(this.infoRes)
            .fontSize(12)
            .fontWeight(350)
            .margin({ top: 4 })
            .fontColor(getTheme(this.theme).color_text_minor)
            .align(Alignment.Start)
            .width('100%')
        }
      }
      .layoutWeight(1)
      if (this.setting.onClick) {
        Image($r('app.media.ic_enter'))
          .width(18)
          .height(24)
          .objectFit(ImageFit.Contain)
      }

      Blank()
    }
    .padding(16)
    .width('100%')
    .onClick((event) => {
      if (this.setting.onClick) {
        this.setting.onClick(this.setting, () => {
          this.info = this.setting.info.toString()
        }, event)
      }
    })
  }
}


@Preview
@Component
struct ToggleSettingRow {
  @StorageLink('theme') theme: number = 0
  @State setting: SettingItem = null
  @State isOn: boolean = false
  @State rowWidth: number = 0
  @State toggleX: number = 0
  private preference: Preference<boolean>

  aboutToAppear() {
    this.preference = this.setting.preference
    this.isOn = DataStore.get(this.preference.key, this.preference.defaultValue)
  }

  build() {
    Row() {
      if (this.setting.icon) {
        Image(this.setting.icon)
          .width(24)
          .height(24)
          .margin({ right: 16 })
          .fillColor(this.setting.iconBlendColor)
          .objectFit(ImageFit.Contain)
      }

      Column() {
        Text(this.setting.title)
          .fontSize(15)
          .fontWeight(450)
          .fontColor(getTheme(this.theme).color_text_major)
          .align(Alignment.Start)
          .width('100%')
        Text(this.setting.info)
          .fontSize(12)
          .fontWeight(350)
          .margin({ top: 4 })
          .fontColor(getTheme(this.theme).color_text_minor)
          .align(Alignment.Start)
          .width('100%')
      }
      .layoutWeight(1)

      Toggle({ type: ToggleType.Switch, isOn: this.isOn })
        .selectedColor(getTheme(this.theme).primary_color)
        .hitTestBehavior(HitTestMode.Transparent)
        .responseRegion({
          x: -this.toggleX,
          y: 0,
          width: this.rowWidth,
          height: '100%'
        })
        .onChange((isOn) => {
          this.isOn = isOn
          if (this.preference.onValueChange) {
            this.preference.onValueChange(this.preference.key, isOn)
          }
        })
        .onAreaChange((_, newArea) => {
          Logger.e(this, 'onAreaChange newArea=' + JSON.stringify(newArea))
          this.toggleX = parseInt(newArea.position.x.toString())
        })

      Blank()
    }
    .padding(16)
    .width('100%')
    .onAreaChange((_, newArea) => {
      Logger.e(this, 'onAreaChange newArea=' + JSON.stringify(newArea))
      this.rowWidth = parseInt(newArea.width.toString())
    })
  }
}

@Preview
@Component
struct RadioSettingRow {
  @StorageLink('theme') theme: number = 0
  @State setting: SettingItem = null
  @State index: number = 0
  @State info: string = ''
  private preference: Preference<number>

  // 创建一个controller
  private sourceController: CustomDialogController

  aboutToAppear() {
    this.preference = this.setting.preference
    this.index = DataStore.get(this.preference.key, this.preference.defaultValue)
    if (this.preference.values) {
      this.info = this.preference.values[this.index]
    } else {
      this.info = this.setting.info.toString()
    }
    this.sourceController = new CustomDialogController({
      builder: RadioDialog({
        title: this.setting.title,
        prefKey: this.preference.key,
        values: this.preference.values,
        onSelect: (index) => {
          this.index = index
          if (this.preference.values) {
            this.info = this.preference.values[this.index]
          }
        }
      }),
      cancel: () => {
        console.log("cancel")
      },
      autoCancel: true,
      customStyle: true
    });
  }

  build() {
    Row() {
      if (this.setting.icon) {
        Image(this.setting.icon)
          .width(24)
          .height(24)
          .margin({ right: 16 })
          .fillColor(this.setting.iconBlendColor)
          .objectFit(ImageFit.Contain)
      }

      Column() {
        Text(this.setting.title)
          .fontSize(15)
          .fontWeight(450)
          .fontColor(getTheme(this.theme).color_text_major)
          .align(Alignment.Start)
          .width('100%')
        Text(this.info)
          .fontSize(12)
          .fontWeight(350)
          .margin({ top: 4 })
          .fontColor(getTheme(this.theme).color_text_minor)
          .align(Alignment.Start)
          .width('100%')
      }
      .layoutWeight(1)

      Image($r('app.media.ic_enter'))
        .width(18)
        .height(24)
        .objectFit(ImageFit.Contain)

      Blank()
    }
    .padding(16)
    .width('100%')
    .onClick((event) => {
      //      if (this.setting.onClick) {
      //        this.setting.onClick(event)
      //      }
      this.sourceController.open()
    })
  }
}

@Component
export struct SettingsContainer {
  @StorageLink('theme') theme: number = 0
  private group: SettingGroup

  build() {
    Column() {
      if (this.group.title) {
        Row() {
          Row()
            .backgroundColor(getTheme(this.theme).primary_color)
            .height(14)
            .width(6)
            .margin({ right: 2 })
            .borderRadius(4)
          Text(this.group.title)
            .fontColor(getTheme(this.theme).color_text_major)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)

          Blank()
        }
        .padding({ left: 16, top: 16, right: 16, bottom: 8 })
        .width('100%')
      }

      ForEach(this.group.settings, (setting: SettingItem) => {
        if (setting.preference) {
          if (setting.preference.type === 'switch') {
            ToggleSettingRow({ setting: setting })
          } else if (setting.preference.type == 'radio') {
            RadioSettingRow({ setting: setting })
          } else {
            SettingRow({ setting: setting })
          }
        } else {
          SettingRow({ setting: setting })
        }
      })
    }
    .backgroundColor(getTheme(this.theme).background_color)
    .borderRadius(16)
  }
}

@Component
export struct SettingsList {
  private settings: SettingGroup[]

  build() {
    Column() {
      Scroll() {
        Column() {
          ForEach(this.settings, (group, index) => {
            SettingsContainer({ group: group })
            if (index < this.settings.length - 1) {
              Blank().height(16)
            }
          })
        }
        .padding(16)
        .width('100%')
        .constraintSize({
          minHeight: '100%'
        })
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
  }
}