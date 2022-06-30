class LIFO<E> {
  LIFO() : _storage = <E>[];
  final List<E> _storage;

  void clear() => _storage.clear();

  void push(E element) => _storage.add(element);
  E pop() => _storage.removeLast();

  E get peek => _storage.last;

  bool get isEmpty => _storage.isEmpty;
  bool get isNotEmpty => !isEmpty;
}