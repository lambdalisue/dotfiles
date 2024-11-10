import { assertType, IsExact } from "jsr:@std/testing/types";
import { Curator, IdItem, Source } from "jsr:@vim-fall/std@^0.2.0-pre.1";

type FlatType<T> = T extends Record<PropertyKey, unknown>
  ? { [K in keyof T]: FlatType<T[K]> }
  : T;

export type Modifier<T, U = T> =
  & (<
    S extends Source<T> | Curator<T>,
    V extends S extends (Source<infer V> | Curator<infer V>) ? V : never,
    R extends S extends Source<T> ? Source<FlatType<V & U>>
      : Curator<FlatType<V & U>>,
  >(source: S) => R)
  & {
    __phantom?: (_: T) => void;
  };

type ModifierA<T> = T extends Modifier<infer A, infer _> ? A : never;
type ModifierB<T> = T extends Modifier<infer _, infer B> ? B : never;

// export type Modifier<T, U> =
//   & (<
//     S extends Source<T>,
//     V extends S extends Source<infer V> ? V : never,
//     R extends S extends Source<unknown> ? Source<FlatType<V & U>> : never,
//   >(source: S) => R)
//   & {
//     __phantom?: (_: T) => void;
//   };
//

type PipeModifiers<Modifiers extends Modifier<any, any>[], Input> =
  Modifiers extends [infer Head, ...infer Tail extends Modifier<any, any>[]] ? [
      Modifier<Input, ModifierB<Head>>,
      ...PipeModifiers<Tail, ModifierB<Head>>,
    ]
    : Modifiers;

type PipeModifiersOutput<Modifiers extends Modifier<any, any>[]> =
  Modifiers extends [infer Head] ? ModifierB<Head>
    : Modifiers extends [infer Head, ...infer Tail extends Modifier<any, any>[]]
      ? ModifierB<Head> & PipeModifiersOutput<Tail>
    : never;

export function composeModifiers<
  Input,
  Modifiers extends Modifier<any, any>[],
>(
  ...modifiers: PipeModifiers<Modifiers, Input>
): Modifier<Input, FlatType<PipeModifiersOutput<Modifiers>>> {
  throw new Error("Not implemented");
}

// export function composeModifiers<
//   M1 extends Modifier<any, any>,
//   M2 extends Modifier<ModifierB<M1>, any>,
//   M3 extends Modifier<ModifierB<M2>, any>,
// >(
//   a: M1,
//   b: M2,
//   c: M3,
// ): Modifier<
//   ModifierA<M1>,
//   FlatType<ModifierB<M1> & ModifierB<M2> & ModifierB<M3>>
// > {
//   throw new Error("Not implemented");
// }

function defineMockModifier<T, U>() {
  return {} as Modifier<T, U>;
}

const source = {} as Source<{ a: string; A: string }>;
const modifier1 = defineMockModifier<
  { a: string },
  { b: string; B: string }
>();
const modifier2 = defineMockModifier<
  { b: string },
  { c: string; C: string }
>();
const modifier3 = defineMockModifier<
  { c: string },
  { d: string; D: string }
>();

const composed = composeModifiers(
  modifier1,
  modifier2,
  modifier3,
);
composeModifiers(
  modifier1,
  // @ts-expect-error: modifier3 requires { c: string }
  modifier3,
  modifier2,
);
const composedSource = composed(source);
assertType<
  IsExact<
    typeof composedSource,
    Source<{
      a: string;
      b: string;
      c: string;
      d: string;
      A: string;
      B: string;
      C: string;
      D: string;
    }>
  >
>(true);
//
// const composedLeft = composeModifiersLeft(
//   modifier1,
//   modifier2,
//   modifier3,
// );
// composeModifiersLeft(
//   modifier1,
//   // @ts-expect-error: modifier3 requires { c: string }
//   modifier3,
//   modifier2,
// );
// const composedLeftSource = composedLeft(source);
// assertType<
//   IsExact<
//     typeof composedLeftSource,
//     Source<{
//       a: string;
//       b: string;
//       c: string;
//       d: string;
//       A: string;
//       B: string;
//       C: string;
//       D: string;
//     }>
//   >
// >(true);
