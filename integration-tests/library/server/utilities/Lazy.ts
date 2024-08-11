export class Lazy<T> {
  private value?: T

  constructor(private readonly factory: () => T) {}

  get(): T {
    if (this.value === undefined) {
      this.value = this.factory()
    }
    return this.value
  }
}
