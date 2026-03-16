using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlIsNullBooleanExpression))]
    internal sealed class SqlScriptIsNullBooleanExpression : SqlScriptBooleanExpression<SqlIsNullBooleanExpression>
        {
        public Boolean HasNot { get { return Source.HasNot; }}

        #region ctor{IServiceProvider,SqlIsNullBooleanExpression}
        public SqlScriptIsNullBooleanExpression(IServiceProvider context,SqlIsNullBooleanExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }