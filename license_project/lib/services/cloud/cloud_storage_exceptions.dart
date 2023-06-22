class CloudStorageException implements Exception {
  const CloudStorageException();
}

class CloudGetException extends CloudStorageException {}

class CloudNotUpdateFavouritesException extends CloudStorageException {}

class CloudNotDeleteFavouriteException extends CloudStorageException {}
