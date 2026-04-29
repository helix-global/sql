using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal static class Extensions
        {
        #region M:ForEach<T>({this}IEnumerable<T>,Action<T>)
        public static void ForEach<T>(this IEnumerable<T> values, Action<T> action) {
            if (action == null) { throw new ArgumentNullException(nameof(action)); }
            if (values != null){
                foreach (var value in values){
                    action(value);
                    }
                }
            }
        #endregion
        #region M:AddRange<T>({this}IList<T>,IEnumerable<T>)
        public static void AddRange<T>(this IList<T> target,IEnumerable<T> source) {
            foreach (var item in source) {
                target.Add(item);
                }
            }
        #endregion
        #region M:AsReadOnly<T>({this}IEnumerable<T>):IList<T>
        public static IList<T> AsReadOnly<T>(this IEnumerable<T> source)
            {
            return new ReadOnlyCollection<T>(source.ToArray());
            }
        #endregion
        #region M:AsReadOnly<K,T>({this}IDictionary<K,T>):IDictionary<K,T>
        /// <summary>Returns a read-only wrapper for the specified dictionary.</summary>
        /// <typeparam name="K">The type of keys in the dictionary.</typeparam>
        /// <typeparam name="T">The type of values in the dictionary.</typeparam>
        /// <param name="source">The dictionary to wrap in a read-only wrapper. Cannot be <see langword="null"/>.</param>
        /// <returns>A read-only IDictionary<TKey,TValue> wrapper around the specified dictionary.</returns>
        public static IDictionary<K,T> AsReadOnly<K,T>(this IDictionary<K,T> source)
            {
            return new ReadOnlyDictionary<K,T>(source);
            }
        #endregion
        }
    }
