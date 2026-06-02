using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [DebuggerDisplay("Count = {Count}")]
    public class SqlObjectCollection<T> : IList<T>
        {
        #region M:IEnumerable<T>.GetEnumerator:IEnumerator<T>
        /// <summary>Returns an enumerator that iterates through the collection.</summary>
        /// <returns>An enumerator that can be used to iterate through the collection.</returns>
        public IEnumerator<T> GetEnumerator()
            {
            e.Wait();
            return values.GetEnumerator();
            }
        #endregion
        #region M:IEnumerable.GetEnumerator:IEnumerator
        /// <summary>Returns an enumerator that iterates through a collection.</summary>
        /// <returns>An <see cref="T:System.Collections.IEnumerator"/> object that can be used to iterate through the collection.</returns>
        IEnumerator IEnumerable.GetEnumerator()
            {
            return GetEnumerator();
            }
        #endregion
        #region M:ICollection<T>.Add(T)
        /// <summary>Adds an item to the <see cref="T:System.Collections.Generic.ICollection`1"/>.</summary>
        /// <param name="item">The object to add to the <see cref="T:System.Collections.Generic.ICollection`1"/>.</param>
        /// <exception cref="T:System.NotSupportedException">The <see cref="T:System.Collections.Generic.ICollection`1"/> is read-only.</exception>
        void ICollection<T>.Add(T item)
            {
            throw new ReadOnlyException();
            }
        #endregion
        #region M:ICollection<T>.Clear
        /// <summary>Removes all items from the <see cref="T:System.Collections.Generic.ICollection`1"/>.</summary>
        /// <exception cref="T:System.NotSupportedException">The <see cref="T:System.Collections.Generic.ICollection`1"/> is read-only.</exception>
        void ICollection<T>.Clear()
            {
            throw new ReadOnlyException();
            }
        #endregion
        #region M:ICollection<T>.Contains(T):Boolean
        /// <summary>Determines whether the <see cref="T:System.Collections.Generic.ICollection`1"/> contains a specific value.</summary>
        /// <param name="item">The object to locate in the <see cref="T:System.Collections.Generic.ICollection`1"/>.</param>
        /// <returns><see langword="true"/> if <paramref name="item"/> is found in the <see cref="T:System.Collections.Generic.ICollection`1"/>; otherwise, <see langword="false"/>.</returns>
        Boolean ICollection<T>.Contains(T item)
            {
            e.Wait();
            return values.Contains(item);
            }
        #endregion
        #region M:ICollection<T>.CopyTo(T[],Int32)
        /// <summary>Copies the elements of the <see cref="T:System.Collections.Generic.ICollection`1"/> to an <see cref="T:System.Array"/>, starting at a particular <see cref="T:System.Array"/> index.</summary>
        /// <param name="array">The one-dimensional <see cref="T:System.Array"/> that is the destination of the elements copied from <see cref="T:System.Collections.Generic.ICollection`1"/>. The <see cref="T:System.Array"/> must have zero-based indexing.</param>
        /// <param name="arrayIndex">The zero-based index in <paramref name="array"/> at which copying begins.</param>
        /// <exception cref="T:System.ArgumentNullException"><paramref name="array"/> is <see langword="null"/>.</exception>
        /// <exception cref="T:System.ArgumentOutOfRangeException"><paramref name="arrayIndex"/> is less than 0.</exception>
        /// <exception cref="T:System.ArgumentException">The number of elements in the source <see cref="T:System.Collections.Generic.ICollection`1"/> is greater than the available space from <paramref name="arrayIndex"/> to the end of the destination <paramref name="array"/>.</exception>
        void ICollection<T>.CopyTo(T[] array, Int32 arrayIndex)
            {
            e.Wait();
            values.CopyTo(array,arrayIndex);
            }
        #endregion
        #region M:ICollection<T>.Remove(T):Boolean
        /// <summary>Removes the first occurrence of a specific object from the <see cref="T:System.Collections.Generic.ICollection`1"/>.</summary>
        /// <param name="item">The object to remove from the <see cref="T:System.Collections.Generic.ICollection`1"/>.</param>
        /// <returns><see langword="true"/> if <paramref name="item"/> was successfully removed from the <see cref="T:System.Collections.Generic.ICollection`1"/>; otherwise, <see langword="false"/>. This method also returns <see langword="false"/> if <paramref name="item"/> is not found in the original <see cref="T:System.Collections.Generic.ICollection`1"/>.</returns>
        /// <exception cref="T:System.NotSupportedException">The <see cref="T:System.Collections.Generic.ICollection`1"/> is read-only.</exception>
        Boolean ICollection<T>.Remove(T item)
            {
            throw new ReadOnlyException();
            }
        #endregion
        #region P:ICollection<T>.Count:Int32
        /// <summary>Gets the number of elements contained in the <see cref="T:System.Collections.Generic.ICollection`1"/>.</summary>
        /// <returns>The number of elements contained in the <see cref="T:System.Collections.Generic.ICollection`1"/>.</returns>
        public Int32 Count { get {
            e.Wait();
            return values.Count;
            }}
        #endregion
        #region P:ICollection<T>.IsReadOnly:Boolean
        /// <summary>Gets a value indicating whether the <see cref="T:System.Collections.Generic.ICollection`1" /> is read-only.</summary>
        /// <returns><see langword="true"/> if the <see cref="T:System.Collections.Generic.ICollection`1"/> is read-only; otherwise, <see langword="false"/>.</returns>
        Boolean ICollection<T>.IsReadOnly
            {
            get { return true; }
            }
        #endregion
        #region M:IList<T>.IndexOf(T)
        /// <summary>Determines the index of a specific item in the <see cref="T:System.Collections.Generic.IList`1"/>.</summary>
        /// <param name="item">The object to locate in the <see cref="T:System.Collections.Generic.IList`1"/>.</param>
        /// <returns>The index of <paramref name="item"/> if found in the list; otherwise, -1.</returns>
        Int32 IList<T>.IndexOf(T item)
            {
            e.Wait();
            return values.IndexOf(item);
            }
        #endregion
        #region M:IList<T>.Insert(Int32,T)
        /// <summary>Inserts an item to the <see cref="T:System.Collections.Generic.IList`1"/> at the specified index.</summary>
        /// <param name="index">The zero-based index at which <paramref name="item"/> should be inserted.</param>
        /// <param name="item">The object to insert into the <see cref="T:System.Collections.Generic.IList`1"/>.</param>
        /// <exception cref="T:System.ArgumentOutOfRangeException"><paramref name="index"/> is not a valid index in the <see cref="T:System.Collections.Generic.IList`1"/>.</exception>
        /// <exception cref="T:System.NotSupportedException">The <see cref="T:System.Collections.Generic.IList`1"/> is read-only.</exception>
        void IList<T>.Insert(Int32 index, T item)
            {
            throw new ReadOnlyException();
            }
        #endregion
        #region M:IList<T>.RemoveAt(Int32)
        /// <summary>Removes the <see cref="T:System.Collections.Generic.IList`1"/> item at the specified index.</summary>
        /// <param name="index">The zero-based index of the item to remove.</param>
        /// <exception cref="T:System.ArgumentOutOfRangeException"><paramref name="index"/> is not a valid index in the <see cref="T:System.Collections.Generic.IList`1"/>.</exception>
        /// <exception cref="T:System.NotSupportedException">The <see cref="T:System.Collections.Generic.IList`1"/> is read-only.</exception>
        void IList<T>.RemoveAt(Int32 index)
            {
            throw new ReadOnlyException();
            }
        #endregion
        #region M:IList<T>.this[Int32]:T
        /// <summary>Gets or sets the element at the specified index.</summary>
        /// <param name="index">The zero-based index of the element to get or set.</param>
        /// <returns>The element at the specified index.</returns>
        /// <exception cref="T:System.ArgumentOutOfRangeException"><paramref name="index"/> is not a valid index in the <see cref="T:System.Collections.Generic.IList`1"/>.</exception>
        /// <exception cref="T:System.NotSupportedException">The property is set and the <see cref="T:System.Collections.Generic.IList`1"/> is read-only.</exception>
        T IList<T>.this[Int32 index]
            {
            get
                {
                e.Wait();
                return values[index];
                }
            set
                {
                throw new ReadOnlyException();
                }
            }
        #endregion
        #region M:PrepareChanges:ISqlObjectCollectionChanges<T>
        public ISqlObjectCollectionChanges<T> PrepareChanges()
            {
            return new Changes<T>(this);
            }
        #endregion

        private class Changes<T> : List<T>,ISqlObjectCollectionChanges<T>
            {
            private SqlObjectCollection<T> source;
            public Changes(SqlObjectCollection<T> source)
                {
                this.source = source;
                source.e.Reset();
                }
            public void Dispose() {
                source.values.AddRange(this);
                source.e.Set();
                }
            }

        private readonly IList<T> values = new List<T>();
        private readonly ManualResetEventSlim e = new ManualResetEventSlim(false);
        }
    }
