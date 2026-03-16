using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlUnaryScalarExpression))]
    internal sealed class SqlScriptUnaryScalarExpression : SqlScriptScalarExpression<SqlUnaryScalarExpression>
        {
        public SqlUnaryScalarOperatorType Operator {get{return Source.Operator; }}

        #region ctor{IServiceProvider,SqlUnaryScalarExpression}
        public SqlScriptUnaryScalarExpression(IServiceProvider context,SqlUnaryScalarExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }