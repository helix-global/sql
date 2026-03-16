using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlExistsBooleanExpression))]
    internal sealed class SqlScriptExistsBooleanExpression : SqlScriptBooleanExpression<SqlExistsBooleanExpression>
        {
        #region ctor{IServiceProvider,SqlExistsBooleanExpression}
        public SqlScriptExistsBooleanExpression(IServiceProvider context,SqlExistsBooleanExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }