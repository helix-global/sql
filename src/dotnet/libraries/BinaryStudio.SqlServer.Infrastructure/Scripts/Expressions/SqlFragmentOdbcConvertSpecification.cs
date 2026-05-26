using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(OdbcConvertSpecification))]
    internal sealed class SqlFragmentOdbcConvertSpecification : SqlFragmentScalarExpression<OdbcConvertSpecification>
        {
        #region ctor{IServiceProvider,OdbcConvertSpecification}
        public SqlFragmentOdbcConvertSpecification(IServiceProvider context,OdbcConvertSpecification source)
            : base(context,source)
            {
            }
        #endregion
        }
    }