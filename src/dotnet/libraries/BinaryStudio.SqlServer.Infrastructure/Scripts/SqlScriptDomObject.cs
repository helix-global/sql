using System;
using System.ComponentModel;
using Microsoft.SqlServer.TransactSql.ScriptDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal abstract class SqlScriptDomObject<T> : SqlScriptObject
        where T : TSqlFragment
        {
        protected T Source { get; }

        #region ctor{IServiceProvider,T}
        protected SqlScriptDomObject(IServiceProvider context,T source)
            : base(context,source)
            {
            Source = source;
            }
        #endregion
        #region M:CoerceValue(Type,TypeConverter,Object):Object
        protected override Object CoerceValue(Type targetType,TypeConverter converter,Object value) {
            if (converter == null) { converter = TypeDescriptor.GetConverter(targetType); }
            if (value is TSqlFragment SqlFragment) {
                var r = SqlScriptObjectConverter.CreateFrom(Context,SqlFragment);
                return base.CoerceValue(targetType,converter,r);
                }
            return base.CoerceValue(targetType,converter,value);
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
    }