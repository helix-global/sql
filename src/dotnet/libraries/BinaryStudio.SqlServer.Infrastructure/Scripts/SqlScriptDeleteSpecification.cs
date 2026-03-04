using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlDeleteSpecification))]
    internal sealed class SqlScriptDeleteSpecification : SqlScriptUpdateDeleteSpecificationBase<SqlDeleteSpecification>
        {
        #region ctor{IServiceProvider,SqlDeleteSpecification}
        public SqlScriptDeleteSpecification(IServiceProvider context,SqlDeleteSpecification source)
            : base(context,source)
            {
            }
        #endregion
        }
    }