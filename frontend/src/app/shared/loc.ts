export class Loc {
  readonly fileUrl: string;
  readonly fragmentUrl: string;
  readonly offset: number;
  readonly length: number;
  readonly uri: string;

  constructor(fileUrl: string, fragmentUrl: string, uri: string, offset: number, length: number) {
    this.fileUrl = fileUrl;
    this.fragmentUrl = fragmentUrl;
    this.uri = uri;
    this.offset = offset;
    this.length = length;
  }
}
