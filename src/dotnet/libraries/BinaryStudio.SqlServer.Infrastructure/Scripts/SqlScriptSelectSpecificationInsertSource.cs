using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlSelectSpecificationInsertSource))]
    internal sealed class SqlScriptSelectSpecificationInsertSource : SqlScriptInsertSource<SqlSelectSpecificationInsertSource>
        {
        #region ctor{IServiceProvider,SqlSelectSpecificationInsertSource}
        public SqlScriptSelectSpecificationInsertSource(IServiceProvider context,SqlSelectSpecificationInsertSource source)
            : base(context,source)
            {
            }
        #endregion
        }
    }