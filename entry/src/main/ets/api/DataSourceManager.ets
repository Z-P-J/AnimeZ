import DataStore from '../utils/DataStore';
import BimiAcgDataSource from './impl/BimiAcgDataSource';
import Globals from '../utils/Globals';
import DataSource from './DataSource';

const KEY_CURRENT_SOURCE = 'key_current_source'
const SOURCE_BIMI_ACG = 'source_bimi_acg'

/**
 * 视频数据源管理
 */
export default class DataSourceManager {

  /**
   * 获取当前视频数据源
   */
  static getCurrentSource(): DataSource {
    let currentSource = DataStore.get(KEY_CURRENT_SOURCE, SOURCE_BIMI_ACG)
    return this.getSource(currentSource)
  }

  /**
   * 设置当前视频数据源
   */
  static setCurrentSource(key: string) {
    DataStore.set(KEY_CURRENT_SOURCE, key)
  }

  /**
   * 根据index设置当前数据源
   * @param index
   */
  static setCurrentSourceIndex(index: number) {
    switch (index) {
      case 0:
        this.setCurrentSource(SOURCE_BIMI_ACG)
        break
    }
  }

  /**
   * 根据key获取视频数据源
   */
  static getSource(key: string): DataSource {
    let sourceClass: { new(): DataSource } = null

    switch (key) {
    // TODO 其它数据源
      case SOURCE_BIMI_ACG:
      default:
        sourceClass = BimiAcgDataSource
        break;
    }
    return Globals.get<DataSource>(key, () => {
      return new sourceClass()
    })
  }
}