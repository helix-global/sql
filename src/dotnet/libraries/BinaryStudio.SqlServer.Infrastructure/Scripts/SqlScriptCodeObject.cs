using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;
using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;

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
                        if (RegisteredTypes.TryGetValue(o.GetType(),out var type)) {
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