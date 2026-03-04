using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;
using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Reflection;
using System.Threading;

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
            : base(context,source)
            {
            if (source != null) {
                var children = new List<SqlScriptCodeObject>();
                foreach (var o in source.Children) {
                    if (o != null) {
                        children.Add(CreateObject(context,o));
                        }
                    }
                Children = children.AsReadOnly();
                }
            }
        #endregion
        #region M:CoerceValue(PropertyDescriptor,Object):Object
        protected override Object CoerceValue(PropertyDescriptor descriptor,Object value) {
            if (value is SqlCodeObject SqlCodeObject) {
                if (typeof(SqlScriptCodeObject).IsAssignableFrom(descriptor.PropertyType)) {
                    return CreateObject(Context,SqlCodeObject);
                    }
                }
            return base.CoerceValue(descriptor, value);
            }
        #endregion
        #region M:CreateObject(IServiceProvider,SqlCodeObject):SqlScriptCodeObject
        private static SqlScriptCodeObject CreateObject(IServiceProvider context,SqlCodeObject source) {
            if (source != null) {
                var RequestedType = source.GetType();
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
                    var ctor = type.GetConstructor(new[] { typeof(IServiceProvider), source.GetType() });
                    if (ctor != null) {
                        return (SqlScriptCodeObject)ctor.Invoke(new Object[] { context,source });
                        }
                    }
                throw new ArgumentOutOfRangeException(nameof(source), $"No registered type for {source.GetType()}");
                }
            return null;
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