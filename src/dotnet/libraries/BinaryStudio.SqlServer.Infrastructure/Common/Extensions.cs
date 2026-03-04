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
        }
    }
