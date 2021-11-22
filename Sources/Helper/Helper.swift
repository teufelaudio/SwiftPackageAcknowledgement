import Combine
import Foundation
import FoundationExtensions

public typealias Request = (URLRequest) -> Publishers.Promise<(data: Data, response: URLResponse), URLError>

public typealias Decoder<T> = (Data) -> Result<T, Error>
public typealias Encoder<T> = (T) -> Result<Data, Error>

public typealias PathExists = (String) -> (exists: Bool, isFolder: Bool)
public typealias FileSave = (String, Data) -> Result<Void, Error>
