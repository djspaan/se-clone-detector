export class Loc {
  readonly uri: string;
  private readonly offset: number;
  private readonly length: number;

  constructor(uri: string, offset: number, length: number) {
    this.uri = uri;
    this.offset = offset;
    this.length = length;
  }

  getUri(): string {
    return this.uri;
  }
}
