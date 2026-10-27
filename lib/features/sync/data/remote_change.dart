/// One change reported by the cloud for a collection.
class RemoteChange<T> {
  const RemoteChange.upsert(this.id, T this.model) : removed = false;

  const RemoteChange.removed(this.id)
      : model = null,
        removed = true;

  final String id;
  final T? model;
  final bool removed;
}
