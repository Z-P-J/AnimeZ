import YingHuaDataSource from './impl/YingHuaDataSource';
import DataStore from '../utils/DataStore';
import BimiAcgDataSource from './impl/BimiAcgDataSource';
import Globals from '../utils/Globals';
import DataSource from './DataSource';

const MAP_DATA_SOURCE = 'map_data_source'
const KEY_CURRENT_SOURCE = 'key_current_source'

interface SourceInfo {
  key: string,
  title: string,
  source: { new(): DataSource }
}

const ALL_SOURCES: SourceInfo[] = [
  { key: 'key_yinghuavideo', title: '樱花动漫', source: YingHuaDataSource },
  { key: 'key_bimi_acg', title: 'Bimi动漫（已废弃）', source: BimiAcgDataSource }
]

/**
 * 视频数据源管理
 */
export default class DataSourceManager {

  /**
   * 获取所有数据源
   */
  static getAllSources(): string[] {
    return ALL_SOURCES.map((source) => {
      return source.title
    })
  }

  /**
   * 获取当前视频数据源
   */
  static getCurrentSource(): DataSource {
    let currentSource = DataStore.get(KEY_CURRENT_SOURCE, ALL_SOURCES[0].key)
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
    if (ALL_SOURCES.length > index) {
      this.setCurrentSource(ALL_SOURCES[index].key)
    }
  }

  /**
   * 根据key获取视频数据源
   */
  static getSource(key: string): DataSource {
    const map = this.getSourceMap();
    const source = map.get(key)
    if (source) {
      return source
    }

    let targetSource = ALL_SOURCES.find((source) => {
      return source.key == key
    })
    if (!targetSource) {
      targetSource = ALL_SOURCES[0]
    }
    const newSource = new targetSource.source()
    map.set(key, newSource)
    return newSource
  }

  private static getSourceMap(): Map<string, DataSource> {
    return Globals.get<Map<string, DataSource>>(MAP_DATA_SOURCE, () => {
      const map = new Map<string, DataSource>()
      return map
    })
  }
}