using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlSelectSpecification))]
    internal sealed class SqlScriptSelectSpecification : SqlScriptCodeObject<SqlSelectSpecification>
        {
        #region ctor{IServiceProvider,SqlSelectSpecification}
        public SqlScriptSelectSpecification(IServiceProvider context,SqlSelectSpecification source)
            : base(context,source)
            {
            }
        #endregion
        }
    }