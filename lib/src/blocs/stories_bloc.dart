import 'package:rxdart/rxdart.dart';
import 'dart:async';
import '../models/item_model.dart';
import '../resources/repository.dart';

class StoriesBloc {
  final _repo = Repository();
  final _topIds = PublishSubject<List<int>>();
  final _itemsOutput = BehaviorSubject<Map<int, Future<ItemModel>>>();
  final _itemsFetcher = PublishSubject<int>();

  StoriesBloc() {
    _itemsFetcher.stream
      .transform(_itemsTransformer())
      .pipe(_itemsOutput);
  }

  _itemsTransformer () {
    return ScanStreamTransformer((Map<int, Future<ItemModel>> cache, int id, int index) {
      cache[id] = _repo.fetchItem(id);
      return cache;
    }, <int, Future<ItemModel>>{});
  }

  // Getters to Streams
  Observable<List<int>> get topIds => _topIds.stream;
  Observable<Map<int, Future<ItemModel>>> get items => _itemsOutput.stream;

  // Getters to sinks
  Function(int) get fetchItem => _itemsFetcher.sink.add;

  fetchTopIds() async {
    final ids = await _repo.fetchTopIds();
    _topIds.sink.add(ids);
  }

  clearCache() {
    return _repo.clearCache();
  }

  dispose() {
    _topIds.close();
    _itemsOutput.close();
    _itemsFetcher.close();
  } 
}