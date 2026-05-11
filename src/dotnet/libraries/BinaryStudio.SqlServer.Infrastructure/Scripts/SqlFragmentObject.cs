using System;
using System.ComponentModel;
using System.Globalization;
using System.Linq;
using System.Text;
using Microsoft.SqlServer.TransactSql.ScriptDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal abstract class SqlFragmentObject<T> : SqlScriptObject
        where T : TSqlFragment
        {
        protected String Script { get; }
        protected internal T Source { get; }

        #region ctor{IServiceProvider,T}
        protected SqlFragmentObject(IServiceProvider context,T source)
            : base(context,source)
            {
            Source = source;
            if (source != null) {
                if (source.ScriptTokenStream != null) {
                    var script = new StringBuilder();
                    for (var i = source.FirstTokenIndex;i <= source.LastTokenIndex; i++) {
                        script.Append(source.ScriptTokenStream[i].Text);
                        }
                    Script = script.ToString();
                    }
                }
            }
        #endregion
        #region M:CoerceValue(Type,TypeConverter,Object):Object
        protected override Object CoerceValue(TypeConverter converter,ITypeDescriptorContext context,CultureInfo culture,Object value,Type targetType) {
            if (converter == null) { converter = TypeDescriptor.GetConverter(targetType); }
            if (value is TSqlFragment SqlFragment) {
                if (SqlFragment is MultiPartIdentifier MultiPartIdentifier) { return base.CoerceValue(converter,context,culture,SqlObjectIdentifier.Create(MultiPartIdentifier.Identifiers.Select(i => new SqlIdentifier(i.Value))),targetType); }
                if (SqlFragment is Identifier Identifier) { return base.CoerceValue(converter,context,culture,new SqlIdentifier(Identifier.Value),targetType); }
                if (SqlFragment is IndexExpressionOption ExpressionOption) {
                    switch (ExpressionOption.OptionKind)
                        {
                        case IndexOptionKind.FillFactor: return base.CoerceValue(converter,context,culture,new SqlFragmentFillFactorIndexOption(Context, ExpressionOption),targetType);
                        }
                    }
                var r = SqlScriptObjectConverter.CreateFrom(Context,SqlFragment);
                return base.CoerceValue(converter,context,culture,r,targetType);
                }
            return base.CoerceValue(converter,context,culture,value,targetType);
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