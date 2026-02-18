using System;
using System.Collections.Generic;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal static class Extensions
        {
        public static void ForEach<T>(this IEnumerable<T> values, Action<T> action) {
            if (action == null) { throw new ArgumentNullException(nameof(action)); }
            if (values != null){
                foreach (var value in values){
                    action(value);
                    }
                }
            }

        public static void AddRange<T>(this IList<T> target,IEnumerable<T> source) {
            foreach (var item in source) {
                target.Add(item);
                }
            }
        }
    }
