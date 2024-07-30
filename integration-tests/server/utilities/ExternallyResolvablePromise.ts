export class ExternallyResolvablePromise<T> {
  public promise: Promise<T>
  public resolve!: (value: T | PromiseLike<T>) => void
  public reject!: () => void

  constructor() {
    this.promise = new Promise<T>((resolve, reject) => {
      this.resolve = resolve
      this.reject = reject
    })
  }
}
