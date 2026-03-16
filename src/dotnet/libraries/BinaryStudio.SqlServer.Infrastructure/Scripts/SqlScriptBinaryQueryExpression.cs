using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlBinaryQueryExpression))]
    internal sealed class SqlScriptBinaryQueryExpression : SqlScriptQueryExpression<SqlBinaryQueryExpression>
        {
        #region ctor{IServiceProvider,SqlBinaryQueryExpression}
        public SqlScriptBinaryQueryExpression(IServiceProvider context,SqlBinaryQueryExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }