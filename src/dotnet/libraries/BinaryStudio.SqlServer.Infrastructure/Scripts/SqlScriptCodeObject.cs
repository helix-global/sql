using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Threading;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal class SqlScriptCodeObject<T> : SqlScriptCodeObject
        where T: SqlCodeObject
        {
        protected T Source { get; }

        #region ctor{IServiceProvider,T}
        protected SqlScriptCodeObject(IServiceProvider context,T source)
            :base(context,source)
            {
            Source = source;
            }
        #endregion

        #region M:ToString:String
        /// <summary>Returns a string that represents the current object.</summary>
        /// <returns>A string that represents the current object.</returns>
        public override String ToString()
            {
            return $"{{{typeof(T).Name}}}";
            }
        #endregion
        }

    internal class SqlScriptCodeObject : SqlModelObject
        {
        protected IList<SqlScriptCodeObject> Children { get; } = Array.Empty<SqlScriptCodeObject>();

        #region ctor{IServiceProvider,SqlCodeObject}
        protected SqlScriptCodeObject(IServiceProvider context,SqlCodeObject source)
            : base(context)
            {
            if (source != null) {
                var children = new List<SqlScriptCodeObject>();
                foreach (var o in source.Children) {
                    if (o != null) {
                        var RequestedType = o.GetType();
                        Type type;
                        using (UpgradeableReadLock(g_rtlock)) {
                            if (!RegisteredTypes.TryGetValue(RequestedType,out type)) {
                                foreach (var pair in RegisteredTypes) {
                                    if (pair.Key.IsAssignableFrom(RequestedType)) {
                                        using (WriteLock(g_rtlock)) {
                                            RegisteredTypes[RequestedType] = type = pair.Value;
                                            }
                                        }
                                    }
                                }
                            }
                        if (type != null) {
                            var ctor = type.GetConstructor(new[] { typeof(IServiceProvider), o.GetType() });
                            if (ctor != null) {
                                children.Add((SqlScriptCodeObject)ctor.Invoke(new Object[] { context, o }));
                                continue;
                                }
                            }
                        throw new ArgumentOutOfRangeException(nameof(o), $"No registered type for {o.GetType()}");
                        }
                    }
                Children = children.AsReadOnly();
                }
            }
        #endregion

        protected static readonly IDictionary<Type,Type> RegisteredTypes = new ConcurrentDictionary<Type,Type>();
        private static readonly ReaderWriterLockSlim g_rtlock = new ReaderWriterLockSlim();

        static SqlScriptCodeObject() {
            foreach (var type in typeof(SqlScriptCodeObject).Assembly.GetTypes()) {
                var attributes = type.GetCustomAttributes<SqlScriptObjectAttribute>().ToArray();
                if (attributes.Length > 0) {
                    foreach (var attribute in attributes)
                        {
                        try
                            {
                            RegisteredTypes.Add(attribute.Type,type);
                            }
                        catch
                            {
                            throw;
                            }
                        }
                    }
                }
            }
        }
    }